/*
 * sunny_ctrl_test_func.h
 *
 *  Created on: 2026Äê8ÔÂ24ÈÕ
 *      Author: cgliu
 */

#ifndef SRC_SUNNY_CTRL_TEST_FUNC_H_
#define SRC_SUNNY_CTRL_TEST_FUNC_H_


uint32_t reg_read32(uintptr_t reg_phy_addr);
void reg_write32(uintptr_t reg_phy_addr, uint32_t val);
void test_ec_4di_2do();
void test_ec_1di();
void test_ec_1do();
void test_ec_3di_2do();
void test_ec_sf_door();
void test_ec_trayclaw();
void test_ec_2di();
void test_ec_3led_bz();




#endif /* SRC_SUNNY_CTRL_TEST_FUNC_H_ */
