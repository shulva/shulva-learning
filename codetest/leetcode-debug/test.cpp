//
// Created by shulva on 24-9-5.
//
#include "header.h"

int main()
{
    Solution s;
    std::vector<std::vector<char> > height = {
            {'1', '0', '1', '0', '0'},
            {'1', '0', '1', '1', '1'},
            {'1', '1', '1', '1', '1'},
            {'1', '0', '0', '1', '0'}
    };

    vector<string> s1 = {"fooo","barr","wing","ding","wing"};
    ListNode *head = new ListNode(2);
    ListNode *head2 = new ListNode(1);
    head->next = head2;

    vector<vector<int>> g ={{2,1,1},{2,3,1},{3,4,1}};

    vector<int> a ={4,2,4,8,2};
    vector<int> a1 ={5,5,5,10,8};
    vector<int> a2 ={1,2,8,10,4};

    s.networkDelayTime(g,4,2);

}