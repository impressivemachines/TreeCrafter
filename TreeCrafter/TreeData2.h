//
//  TreeData.h
//  Tree Crafter iPad App
//
//  Created by SIMON WINDER on 4/4/13.
//  Copyright (c) 2013 Impressive Machines LLC. All rights reserved.
//

#ifndef __Fractal_Trees__TreeData2__
#define __Fractal_Trees__TreeData2__

struct TreeNode2
{
    TreeFrame frame;
    int level;
    int priority;

    struct TreeNode2 *pLeft;
    struct TreeNode2 *pRight;
    struct TreeNode2 *pCompletedNext;
    struct TreeNode2 *pLevelNext;
    struct TreeNode2 *pFreeNext;
};

class CTreeData2
{
public:
    CTreeData2();
    ~CTreeData2();
    
    void Free();
    void Clear();
    bool Init(int size);

    bool CreateNode(int level, int priority, const TreeFrame &frame);
    TreeNode2 *TransferNode();
    
    bool StartLevelEnumeration(int level);
    TreeNode2 *GetNextLevelNode();
    
    void StartEnumeration() { m_completed_enum_ptr = m_completed_list_head; }
    TreeNode2 *GetNextNode();
    
    int Size() { return m_size; }
    int CountIncomplete() { return m_btreecount; }
    int Count() { return m_count; }
    int CountAtLevel(int level);
    bool Full() { return m_free_list_head==NULL; }
    
private:
    TreeNode2 *m_tree_data_block; // the allocation block
    TreeNode2 *m_free_list_head; // start of free list

    TreeNode2 *m_btree_head; // root of btree
    TreeNode2 *m_rglevel_list_head[MAX_LEVELS]; // roots of levels
    //TreeNode2 *m_rglevel_list_tail[MAX_LEVELS]; // tails of levels
    TreeNode2 *m_completed_list_head; // start of all that are completed
    TreeNode2 *m_completed_list_tail; // last completed entry
    
    TreeNode2 *m_level_enum_ptr; // level enum pointer
    
    TreeNode2 *m_completed_enum_ptr;
    
    int m_size; // allocation size
    int m_count; // count of valid entries
    int m_btreecount; // count of entries in btree
    int m_rgcount_at_level[MAX_LEVELS]; // count for each level
};

#endif /* defined(__Fractal_Trees__TreeData2__) */
