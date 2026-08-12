// @file pl_menu.h
// Interactive UART menu + input mode state machine

#ifndef PL_MENU_H
#define PL_MENU_H

// poll UART, return next key, 0 if none (0xFF noise -> 0)
int MenuPollKey(void);

// handle one key; returns 1 when the app should exit, 0 otherwise
int MenuHandleKey(char key);

void PrintMenu(void);

#endif /* PL_MENU_H */
