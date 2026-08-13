// @file pl_menu.h
// menu + input FSM

#ifndef PL_MENU_H
#define PL_MENU_H

// poll key
int MenuPollKey(void);

// handle key
int MenuHandleKey(char key);

void PrintMenu(void);

#endif /* PL_MENU_H */
