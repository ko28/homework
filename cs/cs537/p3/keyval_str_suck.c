#include <stdlib.h>
#include <string.h>
#include <stdio.h>

// bad key val store via singly linked list 
typedef struct Node {
   char *key;
   char *val;
   struct Node *next;
} Node;
Node *HEAD = NULL;
//Node *init_keyval_head(){
//	return &(Node){NULL, NULL, NULL};
//}

void set (Node *n, char *key, char *val, Node *next){
	n->key = key;
	n->val = val;
	n->next = next;
}

const char *get(Node *HEAD, char *key){
	Node *curr = HEAD;
	while(curr != NULL){
		if(strcmp(curr->key, key) == 0){
			return curr->val;
		}
		curr = curr->next;
	}
	return NULL;
}

// Insert at the front of list 
void insert (Node *HEAD, char *key, char *val) {
	// empty linked list
	if(HEAD == NULL){
		HEAD = malloc(sizeof(Node));
		set(HEAD, key, val, NULL);
	}
	else{
		Node *NEW_HEAD = malloc(sizeof(Node));
		set(NEW_HEAD, key, val, HEAD);
		HEAD = NEW_HEAD;
	}
}

// Insert at the front of list 
void insert2 (Node **HEAD, char *key, char *val) {
	Node *NEW_HEAD = malloc(sizeof(Node));
	set(NEW_HEAD, key, val, *HEAD);
	*HEAD = NEW_HEAD;
}

void delete (Node *HEAD, char *key) {
	Node *curr = HEAD;
	Node *prev = NULL;
	while(curr != NULL){
		if(strcmp(curr->key, key) == 0){
			prev->next = curr->next;
			free(curr);
			return;
		}
		curr = curr->next;
		prev = curr;
	}
}	

void print_list(Node *HEAD){
	while(HEAD != NULL) {
		printf("Key: %s\tVal: %s\n", HEAD->key, HEAD->val);
		HEAD = HEAD->next;
	}
}


int main(){
	printf("Hello\n");
	
	insert2(&HEAD, "wow", "val");
	insert2(&HEAD, "boop", "yes");
	insert2(&HEAD, "noo", "vaeeeel");
	delete(HEAD, "wow");
	print_list(HEAD);	
	free(HEAD);
}