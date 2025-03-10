*********************************************
***  Senior High School Sample Analyzing  ***
*********************************************

if "`c(username)'" == "Administrator" {  
    global do = "C:\Users\Administrator\Desktop\LaborTopicTermPaper\do"
    global rawData = "C:\Users\Administrator\Desktop\LaborTopicTermPaper\rawData"
    global workData = "C:\Users\Administrator\Desktop\LaborTopicTermPaper\workData"
    global log = "C:\Users\Administrator\Desktop\LaborTopicTermPaper\log"
    global pic = "C:\Users\Administrator\Desktop\LaborTopicTermPaper\pic"
}
if "`c(username)'" == "jwutw" {
	global do = "C:\Users\jwutw\OneDrive\桌面\大四下資料\勞動經濟學\Git\LaborTopicTermPaper\do"
	global rawData = "C:\Users\jwutw\OneDrive\桌面\大四下資料\勞動經濟學\Git\LaborTopicTermPaper\rawData"
	global workData = "C:\Users\jwutw\OneDrive\桌面\大四下資料\勞動經濟學\Git\LaborTopicTermPaper\workData"
	global log = "C:\Users\jwutw\OneDrive\桌面\大四下資料\勞動經濟學\Git\LaborTopicTermPaper\log"
	global pic = "C:\Users\jwutw\OneDrive\桌面\大四下資料\勞動經濟學\Git\LaborTopicTermPaper\pic"
}

* Prepare the dataset
*do "$do/SH_clean.do"
use "$workData\SH_divorce_outcome2009_outcome2015.dta", clear


********************************************
***           Baseline Model             ***
********************************************

* Outcome Variable (1): University
qui reg university divorce, r               // t = -3.81 √
est sto university_1
qui reg university severe_divorce, r        // t = 0.532
est sto university_2
* Outcome Variable (2): Public University
qui reg public divorce, r                   // t = -0.84 
est sto public_1
qui reg public severe_divorce, r            // t = 0.07
est sto public_2

qui reg all_public divorce, r            // t = -1.13
qui reg all_public severe_divorce, r     // t = 0.18

* Outcome Variable (3): Wage Level at 2009
qui reg wage_level_2009 divorce, r          // t = 0.97
est sto wage_level_2009_1
qui reg wage_level_2009 severe_divorce, r   // t = 0.41
est sto wage_level_2009_2


* Outcome Variable (4): Wage Level at 2015
qui reg wage_level_2015 divorce, r          // t = 0.30
est sto wage_level_2015_1
qui reg wage_level_2015 severe_divorce, r   // t = 1.90 √
est sto wage_level_2015_2

* Outcome Variable (5): Working Year at 2009
qui reg work_year_2009 divorce, r           // t = 3.13 √
est sto work_year_2009_1

* Outcome Variable (6): Working Year at 2015
qui reg work_year_2015 divorce, r           // t = 1.40
est sto work_year_2015_1



********************************************
***           Adding Confounder          ***
********************************************

* Import Data
merge 1:1 stud_id using "$workData\SH_parent2001.dta", nogenerate

* Outcome Variable (1): University
qui reg university divorce female hs_private hs_urban general_high i.faedu i.moedu, r               // t = -3.20 √
est sto university_3
qui reg university severe_divorce female hs_private hs_urban general_high i.faedu i.moedu, r        // t = -0.87
est sto university_4

* Outcome Variable (2): Public University
qui reg public divorce female hs_private hs_urban general_high i.faedu i.moedu, r                   // t = 0.24 
est sto public_3
qui reg public severe_divorce female hs_private hs_urban general_high i.faedu i.moedu, r            // t = -0.05
est sto public_4

qui reg all_public divorce female hs_private hs_urban general_high i.faedu i.moedu, r            // t = -0.16
qui reg all_public severe_divorce female hs_private hs_urban general_high i.faedu i.moedu, r     // t = 0.27

* Outcome Variable (3): Wage Level at 2009
qui reg wage_level_2009 divorce female hs_private hs_urban general_high i.faedu i.moedu, r          // t = 1.35
est sto wage_level_2009_3
qui reg wage_level_2009 severe_divorce female hs_private hs_urban general_high i.faedu i.moedu, r   // t = 0.04
est sto wage_level_2009_4

* Outcome Variable (4): Wage Level at 2015
qui reg wage_level_2015 divorce female hs_private hs_urban general_high i.faedu i.moedu, r          // t = 0.92
est sto wage_level_2015_3
qui reg wage_level_2015 severe_divorce female hs_private hs_urban general_high i.faedu i.moedu, r   // t = 1.81 √
est sto wage_level_2015_4

* Outcome Variable (5): Working Year at 2009
qui reg work_year_2009 divorce female hs_private hs_urban general_high i.faedu i.moedu, r           // t = 3.59 √
est sto work_year_2009_2

* Outcome Variable (6): Working Year at 2015
qui reg work_year_2015 divorce female hs_private hs_urban general_high i.faedu i.moedu, r           // t = 0.79
est sto work_year_2015_2

* Outcome Table
esttab university_1 university_2 university_3 university_4, p num
esttab public_1 public_2 public_3 public_4, p num
esttab wage_level_2009_1 wage_level_2009_2 wage_level_2009_3 wage_level_2009_4, p num
esttab wage_level_2015_1 wage_level_2015_2 wage_level_2015_3 wage_level_2015_4, p num
esttab work_year_2009_1 work_year_2009_2 work_year_2015_1 work_year_2015_2, p num



********************************************
***        Post-Double Selection         ***
********************************************

* Merge data with teacher data
foreach i in "c" "d" "e" "m"{
    merge 1:1 stud_id using "$workData\SH_teacher_`i'_2001.dta", nogenerate
}

* define control variables
vl create cf_p_2001 = (w1p308 w1p309 w1p310 w1p311 w1p312 w1p313 ///
                     w1p401 w1p501 w1p502 w1p503 expect_degree w1p511)
vl create stud_info = (female hs_urban hs_capital hs_science general_high)

foreach i in "c" "d" "e" "m"{
    vl create tc_`i'_2001 = (w1t105_`i' w1t106_`i' w1t109_`i' w1t112_`i' w1t113_`i' w1t114_`i' w1t115_`i' w1t116_`i'     ///
            w1t201_`i' w1t202_`i' w1t308_`i' w1t309_`i' w1t311_`i' w1t315_`i' w1t316_`i' w1t318_`i'      ///
            w1t319_`i' w1t320_`i' w1t325_`i' w1t326_`i')
}

* save lasso data for hw2
save "$workData\SH_pds.dta", replace


* pdslasso for university
pdslasso university divorce (i.faedu i.moedu $stud_info $cf_p_2001 $tc_c_2001 $tc_d_2001 $tc_e_2001 $tc_m_2001), rob loption(prestd)
eststo PDS_university
pdslasso university severe_divorce ($cf_2001 $tc_c_2001 $tc_d_2001 $tc_e_2001 $tc_m_2001), rob loption(prestd)
eststo PDS_university_s

* pdslasso for public
pdslasso public divorce (i.faedu i.moedu $stud_info $cf_p_2001 $tc_c_2001 $tc_d_2001 $tc_e_2001 $tc_m_2001), rob loption(prestd)
eststo PDS_public
pdslasso university severe_divorce ($cf_2001 $tc_c_2001 $tc_d_2001 $tc_e_2001 $tc_m_2001), rob loption(prestd)
eststo PDS_public_s

* pdslasso for wage_level_2009
pdslasso wage_level_2009 divorce ($stud_info $cf_p_2001 $tc_c_2001 $tc_d_2001 $tc_e_2001 $tc_m_2001), rob loption(prestd)
eststo PDS_wageLevel_2009
pdslasso wage_level_2009 severe_divorce (i.faedu i.moedu $stud_info $cf_p_2001 $tc_c_2001 $tc_d_2001 $tc_e_2001 $tc_m_2001), rob loption(prestd)
eststo PDS_wageLevel_2009_s

* pdslasso for wage_level_2015
pdslasso wage_level_2015 divorce (i.faedu i.moedu $stud_info $cf_p_2001 $tc_c_2001 $tc_d_2001 $tc_e_2001 $tc_m_2001), rob loption(prestd)
eststo PDS_wageLevel_2015
pdslasso wage_level_2015 severe_divorce (i.faedu i.moedu $stud_info $cf_p_2001 $tc_c_2001 $tc_d_2001 $tc_e_2001 $tc_m_2001), rob
eststo PDS_wageLevel_2015_s

* pdslasso for work_year_2009
pdslasso work_year_2009 divorce ($cf_2001 $tc_c_2001 $tc_d_2001 $tc_e_2001 $tc_m_2001), rob loption(prestd)
eststo PDS_workyear_2009
pdslasso work_year_2009 severe_divorce (i.faedu i.moedu $stud_info $cf_p_2001 $tc_c_2001 $tc_d_2001 $tc_e_2001 $tc_m_2001), rob 
eststo PDS_workyear_2009_s

* pdslasso for work_year_2015
pdslasso work_year_2015 divorce (i.faedu i.moedu $stud_info $cf_p_2001 $tc_c_2001 $tc_d_2001 $tc_e_2001 $tc_m_2001), rob 
eststo PDS_workyear_2015
pdslasso work_year_2015 severe_divorce (i.faedu i.moedu $stud_info $cf_p_2001 $tc_c_2001 $tc_d_2001 $tc_e_2001 $tc_m_2001), rob
eststo PDS_workyear_2015_s


* save table as tex
* Outcome Table
esttab university_1 university_2 university_3 university_4 using "$do\table_tex\SH_table.tex", p num replace
esttab public_1 public_2 public_3 public_4 using "$do\table_tex\SH_table.tex", p num append
esttab wage_level_2009_1 wage_level_2009_2 wage_level_2009_3 wage_level_2009_4 using "$do\table_tex\SH_table.tex", p num append
esttab wage_level_2015_1 wage_level_2015_2 wage_level_2015_3 wage_level_2015_4 using "$do\table_tex\SH_table.tex", p num append
esttab work_year_2009_1 work_year_2009_2 work_year_2015_1 work_year_2015_2 using "$do\table_tex\SH_table.tex", p num append
esttab PDS_university PDS_university_s using "$do\table_tex\SH_table.tex", p num append
esttab PDS_public PDS_public_s using "$do\table_tex\SH_table.tex", p num append
esttab PDS_wageLevel_2009 PDS_wageLevel_2009_s using "$do\table_tex\SH_table.tex", p num append
esttab PDS_wageLevel_2015 PDS_wageLevel_2015_s using "$do\table_tex\SH_table.tex", p num append
esttab PDS_workyear_2009 PDS_workyear_2009_s using "$do\table_tex\SH_table.tex", p num append
esttab PDS_workyear_2015 PDS_workyear_2015_s using "$do\table_tex\SH_table.tex", p num append

