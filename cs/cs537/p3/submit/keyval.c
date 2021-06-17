// Copyright 2020 Daniel Ko
#include "keyval.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
// bad key val/dictionary store via singly linked list

static int BUFFER_SIZE = 512;
Node* HEAD = NULL;

void set(Node* n, char* key, char* val, Node* next) {
  strncpy(n->key, key, BUFFER_SIZE);
  strncpy(n->val, val, BUFFER_SIZE);
  n->next = next;
}

const char* get(char* key) {
  Node* curr = HEAD;
  while (curr != NULL) {
    if (strcmp(curr->key, key) == 0) {
      return curr->val;
    }
    curr = curr->next;
  }
  return NULL;
}

int contains(char* key) {
  Node* curr = HEAD;
  while (curr != NULL) {
    if (strcmp(curr->key, key) == 0) {
      return 1;
    }
    curr = curr->next;
  }
  return 0;
}

// Insert at the front of list
void insert(char* key, char* val) {
  Node* NEW_HEAD = malloc(sizeof(Node));
  NEW_HEAD->key = malloc(sizeof(char) * 512);
  NEW_HEAD->val = malloc(sizeof(char) * 512);
  set(NEW_HEAD, key, val, HEAD);
  HEAD = NEW_HEAD;
}

void delete (char* key) {
  Node* curr = HEAD;
  Node* prev = NULL;
  while (curr != NULL) {
    // Key matches
    if (strcmp(curr->key, key) == 0) {
      // Edge case where we want to remove HEAD
      if (prev == NULL) {
        HEAD = curr->next;
      } else {
        prev->next = curr->next;
      }
      free(curr->key);
      free(curr->val);
      free(curr);
      return;
    }
    prev = curr;
    curr = curr->next;
  }
}

/* void print_list(){
        Node *curr = HEAD;
        while(curr != NULL) {
                printf("%s %s\n", curr->key, curr->val);
                curr = curr->next;
        }
} */

void free_list() {
  Node* curr = HEAD;
  while (curr != NULL) {
    Node* next = curr->next;
    free(curr->key);
    free(curr->val);
    free(curr);
    curr = next;
  }
  HEAD = NULL;
}

