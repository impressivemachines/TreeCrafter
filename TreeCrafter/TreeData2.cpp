//
//  TreeData.cpp
//  Tree Crafter iPad App
//
//  Created by SIMON WINDER on 4/4/13.
//  Copyright (c) 2013 Impressive Machines LLC. All rights reserved.
//

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "fractaltrees.h"
#include "TreeData2.h"

CTreeData2::CTreeData2() : m_tree_data_block(NULL), m_size(0)
{
    Clear();
}

CTreeData2::~CTreeData2()
{
    if(m_tree_data_block)
    {
        delete [] m_tree_data_block;
        DEBUG_PRINTF("deleted CTreeData2 block\n");
    }
}

void CTreeData2::Free()
{
    if(m_tree_data_block)
    {
        delete [] m_tree_data_block;
        DEBUG_PRINTF("deleted CTreeData2 block\n");
    }
    m_tree_data_block = NULL;
    m_size = 0;
    
    Clear();
}

void CTreeData2::Clear()
{
    m_free_list_head = NULL;
    m_btree_head = NULL;
    m_completed_list_head = NULL;
    m_completed_list_tail = NULL;
    m_level_enum_ptr = NULL;
    m_completed_enum_ptr = NULL;
    m_count = 0;
    m_btreecount = 0;
    
    memset(m_rglevel_list_head, 0, MAX_LEVELS * sizeof(TreeNode2 *));
    //memset(m_rglevel_list_tail, 0, MAX_LEVELS * sizeof(TreeNode2 *));
    memset(m_rgcount_at_level, 0, MAX_LEVELS * sizeof(int));
    
    if(m_tree_data_block)
    {
        m_free_list_head = m_tree_data_block;
        int i;
        for(i=0; i<m_size-1; i++)
            m_tree_data_block[i].pFreeNext = &(m_tree_data_block[i+1]);
        m_tree_data_block[i].pFreeNext = NULL;
    }
}

bool CTreeData2::Init(int size)
{
    if(size<1)
        return false;
    
    if(!m_tree_data_block || size != m_size)
    {
        if(m_tree_data_block)
        {
            delete [] m_tree_data_block;
            DEBUG_PRINTF("deleted CTreeData2 block\n");
        }
        
        m_tree_data_block = new TreeNode2 [size];
        DEBUG_PRINTF("allocated CTreeData2 block (%ld)\n", size * sizeof(TreeNode2));
        if(m_tree_data_block==NULL)
        {
            m_size = 0;
            Clear();
            return false;
        }
        
        m_size = size;
    }
    
    Clear();
    
    return true;
}

int CTreeData2::CountAtLevel(int level)
{
    if(level<0 || level>=MAX_LEVELS)
        return 0;
    else
        return m_rgcount_at_level[level];
}

bool CTreeData2::StartLevelEnumeration(int level)
{
    if(level<0 || level>=MAX_LEVELS)
        return false;
    if(m_rglevel_list_head[level]==NULL)
        return false;
    
    m_level_enum_ptr = m_rglevel_list_head[level];
    return true;
}

TreeNode2 *CTreeData2::GetNextLevelNode()
{
    TreeNode2 *p = m_level_enum_ptr;
    if(p)
        m_level_enum_ptr = p->pLevelNext;
    return p;
}

TreeNode2 *CTreeData2::GetNextNode()
{
    TreeNode2 *p = m_completed_enum_ptr;
    if(p)
        m_completed_enum_ptr = p->pCompletedNext;
    return p;
}

bool CTreeData2::CreateNode(int level, int priority, const TreeFrame &frame)
{
    if(level<0 || level>=MAX_LEVELS)
        return false;
    
    if(m_free_list_head==NULL)
    {
        if(m_btree_head==NULL)
            return false; // out of room in the btree
        
        // full, so we might have to displace one
        TreeNode2 *p;
        TreeNode2 *pParent = NULL;
        
        // search for smallest scale in btree
        for(p = m_btree_head; p->pLeft!=NULL; pParent = p, p = p->pLeft);
        
        if(p->frame.scale >= frame.scale)
            return false; // the new node is too small
        
        // delete the smallest one from the btree
        if(pParent!=NULL)
            pParent->pLeft = p->pRight;
        else
            m_btree_head = p->pRight;
        
        // put it back on the free list
        m_free_list_head = p;
        p->pFreeNext = NULL;
    }
    
    // allocate a node
    TreeNode2 *pNode = m_free_list_head;
    m_free_list_head = pNode->pFreeNext;
    
    pNode->level = level;
    pNode->priority = priority;
    pNode->frame = frame;
    pNode->pLeft = NULL;
    pNode->pRight = NULL;
    pNode->pCompletedNext = NULL;
    pNode->pFreeNext = NULL;
    pNode->pLevelNext = NULL;
    
    // link into btree
    if(m_btree_head==NULL)
        m_btree_head = pNode;
    else
    {
        TreeNode2 *p;
        TreeNode2 *pNext;
        
        for(p = m_btree_head; true; p = pNext)
        {
            if(frame.scale < p->frame.scale)
            {
                pNext = p->pLeft;
                if(pNext==NULL)
                {
                    p->pLeft = pNode;
                    break;
                }
            }
            else
            {
                pNext = p->pRight;
                if(pNext==NULL)
                {
                    p->pRight = pNode;
                    break;
                }
            }
        }
    }
    
    return true;
}

TreeNode2 *CTreeData2::TransferNode()
{
    if(m_btree_head==NULL)
        return NULL; // nothing left
    
    // get largest in btree
    TreeNode2 *p;
    TreeNode2 *pParent = NULL;

    for(p = m_btree_head; p->pRight!=NULL; pParent = p, p = p->pRight);
    
    // delete from btree
    if(pParent!=NULL)
        pParent->pRight = p->pLeft;
    else
        m_btree_head = p->pLeft;
  
    // add to completed list
    if(m_completed_list_tail==NULL)
    {
        m_completed_list_head = p;
        m_completed_list_tail = p;
    }
    else
    {
        m_completed_list_tail->pCompletedNext = p;
        m_completed_list_tail = p;
    }
    
    // add to level list
    p->pLevelNext = m_rglevel_list_head[p->level];
    m_rglevel_list_head[p->level] = p;
    
    /*
    if(m_rglevel_list_tail[p->level]==NULL)
    {
        m_rglevel_list_head[p->level] = p;
        m_rglevel_list_tail[p->level] = p;
    }
    else
    {
        m_rglevel_list_tail[p->level]->pLevelNext = p;
        m_rglevel_list_tail[p->level] = p;
    }
    */
    
    m_count++;
    m_rgcount_at_level[p->level]++;

    return p;
}

