#ifndef KEYVAL_H_INCLUDED
#define KEYVAL_H_INCLUDED

typedef struct Node {
   char *key;
   char *val;
   struct Node *next;
} Node;

extern Node *HEAD;

const char *get(char *key);
int contains(char *key);
void set (Node *n, char *key, char *val, Node *next);
void insert(char *key, char *val);
void delete(char *key);
void print_list();
void free_list();

#endif