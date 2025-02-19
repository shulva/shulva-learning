#include <iostream>
#include <vector>
#include <string>
#include <stack>
#include <queue>
using namespace std;


struct TreeNode {
    int val;
    TreeNode *left;
    TreeNode *right;
    TreeNode() : val(0), left(nullptr), right(nullptr) {}
    TreeNode(int x) : val(x), left(nullptr), right(nullptr) {}
    TreeNode(int x, TreeNode *left, TreeNode *right) : val(x), left(left), right(right) {}
};


class Trie {

    bool is_end;
    Trie* letter[26];

public:

    Trie() {
        is_end = false;
        for (int i = 0; i < 26 ; ++i) {
            letter[i] = nullptr;
        }
    }

    void insert(string word) {
        Trie* Word = this;
        for(int i=0;i<word.length();i++)
        {
            int num = word[i]-'a';
            if(!Word->letter[num])
                Word->letter[num]= new Trie();
            Word = Word->letter[num];
        }
        Word->is_end = true;
    }

    bool search(string word) {
        Trie* start = this;
        for(int i=0;i<word.length();i++)
        {
            int num = word[i]-'a';
            if(start->letter[num]==NULL)
                return false;
            start =start ->letter[num];
        }
        return start ->is_end;
    }

    bool startsWith(string prefix) {
        Trie* start = this;
        for(int i=0;i<prefix.length();i++)
        {
            int num =prefix[i]-'a';
            if(start->letter[num]==NULL)
                return false;
            start=start->letter[num];
        }
        return true;
    }

};

