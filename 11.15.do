version 18.0
set more off
isid id year
xtset id year
sort id year
assert _N == 850

global Y gi
global D dt
global X size lev tobinq roa growth dual i.year
global C size lev tobinq roa growth dual

* =========================================================
* Table 4: Baseline DML
preserve
* Reset model variables for this section (global macros are not restored by restore).
global Y gi
global D dt
global X size lev tobinq roa growth dual i.year
capture ddml drop, mname(m0)
set seed 42
ddml init partial, kfolds(5) fcluster(id) tabfold
ddml E[D|X]: pystacked $D $X, type(reg) method(rf)
ddml E[Y|X]: pystacked $Y $X, type(reg) method(rf)
ddml crossfit
ddml estimate, cluster(id)
restore

* =========================================================
* Table 4: Adjusted DT index
preserve
* Reset model variables for this section (global macros are not restored by restore).
global Y gi
global D dt
global X size lev tobinq roa growth dual i.year
global D dt_adj
capture ddml drop, mname(m0)
set seed 42
ddml init partial, kfolds(5) fcluster(id) tabfold
ddml E[D|X]: pystacked $D $X, type(reg) method(rf)
ddml E[Y|X]: pystacked $Y $X, type(reg) method(rf)
ddml crossfit
ddml estimate, cluster(id)
global D dt
restore

* =========================================================
* Table 4: Two-way fixed effects
preserve
* Reset model variables for this section (global macros are not restored by restore).
global Y gi
global D dt
global X size lev tobinq roa growth dual i.year
reghdfe $Y $D $C, absorb(id year) vce(cluster id)
estimates store TWFE_baseline
restore

* =========================================================
* Table 5: 3-fold DML
preserve
* Reset model variables for this section (global macros are not restored by restore).
global Y gi
global D dt
global X size lev tobinq roa growth dual i.year
capture ddml drop, mname(m0)
set seed 42
ddml init partial, kfolds(3) fcluster(id) tabfold
ddml E[D|X]: pystacked $D $X, type(reg) method(rf)
ddml E[Y|X]: pystacked $Y $X, type(reg) method(rf)
ddml crossfit
ddml estimate, cluster(id)
restore

* =========================================================
* Table 5: 8-fold DML
preserve
* Reset model variables for this section (global macros are not restored by restore).
global Y gi
global D dt
global X size lev tobinq roa growth dual i.year
capture ddml drop, mname(m0)
set seed 42
ddml init partial, kfolds(8) fcluster(id) tabfold
ddml E[D|X]: pystacked $D $X, type(reg) method(rf)
ddml E[Y|X]: pystacked $Y $X, type(reg) method(rf)
ddml crossfit
ddml estimate, cluster(id)
restore

* =========================================================
* Table 5: Neural network DML
preserve
* Reset model variables for this section (global macros are not restored by restore).
global Y gi
global D dt
global X size lev tobinq roa growth dual i.year
capture ddml drop, mname(m0)
set seed 42
ddml init partial, kfolds(5) fcluster(id) tabfold
ddml E[D|X]: pystacked $D $X, type(reg) method(nnet)
ddml E[Y|X]: pystacked $Y $X, type(reg) method(nnet)
ddml crossfit
ddml estimate, cluster(id)
restore

* =========================================================
* Table 5: Gradient boosting DML
preserve
* Reset model variables for this section (global macros are not restored by restore).
global Y gi
global D dt
global X size lev tobinq roa growth dual i.year
capture ddml drop, mname(m0)
set seed 42
ddml init partial, kfolds(5) fcluster(id) tabfold
ddml E[D|X]: pystacked $D $X, type(reg) method(gradboost)
ddml E[Y|X]: pystacked $Y $X, type(reg) method(gradboost)
ddml crossfit
ddml estimate, cluster(id)
restore

* =========================================================
* Table 5: 1% winsorization
preserve
* Reset model variables for this section (global macros are not restored by restore).
global Y gi
global D dt
global X size lev tobinq roa growth dual i.year
capture ddml drop, mname(m0)
winsor2 gi dt,replace cuts(1 99)
set seed 42
ddml init partial, kfolds(5) fcluster(id) tabfold
ddml E[D|X]: pystacked $D $X, type(reg) method(rf)
ddml E[Y|X]: pystacked $Y $X, type(reg) method(rf)
ddml crossfit
ddml estimate, cluster(id)
restore

* =========================================================
* Table 5: 5% winsorization
preserve
* Reset model variables for this section (global macros are not restored by restore).
global Y gi
global D dt
global X size lev tobinq roa growth dual i.year
capture ddml drop, mname(m0)
winsor2 gi dt,replace cuts(5 95)
set seed 42
ddml init partial, kfolds(5) fcluster(id) tabfold
ddml E[D|X]: pystacked $D $X, type(reg) method(rf)
ddml E[Y|X]: pystacked $Y $X, type(reg) method(rf)
ddml crossfit
ddml estimate, cluster(id)
restore

* =========================================================
* Table 5: Exclude COVID-19 (2020-2022)
preserve
* Reset model variables for this section (global macros are not restored by restore).
global Y gi
global D dt
global X size lev tobinq roa growth dual i.year
capture ddml drop, mname(m0)
keep if inrange(year, 2014, 2019) | year == 2023
assert _N == 595
set seed 42
ddml init partial, kfolds(5) fcluster(id) tabfold
ddml E[D|X]: pystacked $D $X, type(reg) method(rf)
ddml E[Y|X]: pystacked $Y $X, type(reg) method(rf)
ddml crossfit
ddml estimate, cluster(id)
estimates store DML_noCOVID
restore

* =========================================================
* Table 5: Exclude centrally administered municipalities
* By listed-company REGISTERED address; numeric stock-code IDs
* Beijing: 000970, 300073, 600166
* Shanghai: 002324, 002328, 002454, 600081, 600104, 600741
* Chongqing: 000625; Tianjin: none in the sample
* Do NOT remove 002265: registered in Yunnan, though its office is in Chongqing.
preserve
* Reset model variables for this section (global macros are not restored by restore).
global Y gi
global D dt
global X size lev tobinq roa growth dual i.year
capture ddml drop, mname(m0)
drop if inlist(id, 625, 970, 2324, 2328, 2454)
drop if inlist(id, 300073, 600081, 600104, 600166, 600741)
count
assert _N == 750
bysort id (year): assert _N == 10
xtset id year
set seed 42
ddml init partial, kfolds(5) fcluster(id) tabfold
ddml E[D|X]: pystacked $D $X, type(reg) method(rf)
ddml E[Y|X]: pystacked $Y $X, type(reg) method(rf)
ddml crossfit
ddml estimate, cluster(id)
restore

* =========================================================
* Table 7: Propensity-score matching
preserve
* Reset model variables for this section (global macros are not restored by restore).
global Y gi
global D dt
global X size lev tobinq roa growth dual i.year
egen double psm_dt_median = median(cond(year==2015,dt,.))
gen byte psm_highdt_2015 = (dt>=psm_dt_median) if year==2015 & !missing(dt)
bysort id: egen byte psm_treated = max(psm_highdt_2015)
set seed 20261031
sort id year
psmatch2 psm_treated size lev tobinq roa growth dual if year==2014, logit neighbor(2) caliper(0.05) common
pstest size lev tobinq roa growth dual, both graph
psgraph
gen byte psm_matched_2014 = ((psm_treated==1 & !missing(_nn) & _nn>0) | (psm_treated==0 & !missing(_weight) & _weight>0)) if year==2014 & _support==1
bysort id: egen byte psm_matched_firm = max(psm_matched_2014)
reghdfe gi dt size lev tobinq roa growth dual if psm_matched_firm==1 & inrange(year,2015,2023), absorb(id year) vce(cluster id)
estimates store PSM12_FE
reghdfe gi dt size lev tobinq roa growth dual if inrange(year,2015,2023), absorb(id year) vce(cluster id)
estimates store FE_85
estimates table FE_85 PSM12_FE, keep(dt) b(%9.4f) se(%9.4f) stats(N)
restore

* =========================================================
* Table 6: Instrumental-variable analysis
preserve
* Reset model variables for this section (global macros are not restored by restore).
global Y gi
global D dt
global X size lev tobinq roa growth dual i.year
global IV iv
ivreghdfe $Y $C ($D = $IV), absorb(id year) cluster(id) first
estimates store IV_station
gen byte iv_sample = e(sample)
reghdfe $D $IV $C if iv_sample==1, absorb(id year) vce(cluster id)
test $IV
estimates restore IV_station
restore

* =========================================================
* Table 8: Exploratory mechanism - R&D personnel
preserve
* Reset model variables for this section (global macros are not restored by restore).
global Y gi
global D dt
global X size lev tobinq roa growth dual i.year
foreach model in m0 rd1a rd1b {
    capture ddml drop, mname(`model')
}
global M rdp
gen byte sample_rdp = !missing($Y,$D,$M,size,lev,tobinq,roa,growth,dual,id,year)
assert sample_rdp==1
set seed 42
ddml init partial if sample_rdp==1, kfolds(5) fcluster(id) tabfold
ddml E[D|X]: pystacked $D $X, type(reg) method(rf)
ddml E[Y|X]: pystacked $Y $X, type(reg) method(rf)
ddml crossfit
ddml estimate, cluster(id)
set seed 42
ddml init partial if sample_rdp==1, foldvar(m0_fid_1) mname(rd1a) prefix tabfold
ddml E[D|X], mname(rd1a): pystacked $D $X, type(reg) method(rf)
ddml E[Y|X], mname(rd1a): pystacked $M $X, type(reg) method(rf)
ddml crossfit, mname(rd1a)
ddml estimate, mname(rd1a) cluster(id)
set seed 42
ddml init partial if sample_rdp==1, foldvar(m0_fid_1) mname(rd1b) prefix tabfold
ddml E[Y|X], mname(rd1b): pystacked $Y $X, type(reg) method(rf)
ddml E[D|X], mname(rd1b): pystacked $D $X, type(reg) method(rf)
ddml E[D|X], mname(rd1b): pystacked $M $X, type(reg) method(rf)
ddml crossfit, mname(rd1b)
ddml estimate, mname(rd1b) cluster(id)
ddml estimate, mname(m0) replay
ddml estimate, mname(rd1a) replay
ddml estimate, mname(rd1b) replay
bysort id (year): assert m0_fid_1==m0_fid_1[1]
restore

* =========================================================
* Table 8: Exploratory mechanism - R&D funding
preserve
* Reset model variables for this section (global macros are not restored by restore).
global Y gi
global D dt
global X size lev tobinq roa growth dual i.year
foreach model in m0 rd2a rd2b {
    capture ddml drop, mname(`model')
}
global M rdi
gen byte sample_rdi = !missing($Y,$D,$M,size,lev,tobinq,roa,growth,dual,id,year)
set seed 42
ddml init partial if sample_rdi==1, kfolds(5) fcluster(id) tabfold
ddml E[D|X]: pystacked $D $X, type(reg) method(rf)
ddml E[Y|X]: pystacked $Y $X, type(reg) method(rf)
ddml crossfit
ddml estimate, cluster(id)
set seed 42
ddml init partial if sample_rdi==1, foldvar(m0_fid_1) mname(rd2a) prefix tabfold
ddml E[D|X], mname(rd2a): pystacked $D $X, type(reg) method(rf)
ddml E[Y|X], mname(rd2a): pystacked $M $X, type(reg) method(rf)
ddml crossfit, mname(rd2a)
ddml estimate, mname(rd2a) cluster(id)
set seed 42
ddml init partial if sample_rdi==1, foldvar(m0_fid_1) mname(rd2b) prefix tabfold
ddml E[Y|X], mname(rd2b): pystacked $Y $X, type(reg) method(rf)
ddml E[D|X], mname(rd2b): pystacked $D $X, type(reg) method(rf)
ddml E[D|X], mname(rd2b): pystacked $M $X, type(reg) method(rf)
ddml crossfit, mname(rd2b)
ddml estimate, mname(rd2b) cluster(id)
ddml estimate, mname(m0) replay
ddml estimate, mname(rd2a) replay
ddml estimate, mname(rd2b) replay
restore

* =========================================================
* Table 8: Exploratory mechanism - Human resources
preserve
* Reset model variables for this section (global macros are not restored by restore).
global Y gi
global D dt
global X size lev tobinq roa growth dual i.year
foreach model in m0 hca hcb {
    capture ddml drop, mname(`model')
}
global M hc
confirm numeric variable hc
gen byte sample_hc = !missing($Y,$D,$M,size,lev,tobinq,roa,growth,dual,id,year)
set seed 42
ddml init partial if sample_hc==1, kfolds(5) fcluster(id) tabfold
ddml E[D|X]: pystacked $D $X, type(reg) method(rf)
ddml E[Y|X]: pystacked $Y $X, type(reg) method(rf)
ddml crossfit
ddml estimate, cluster(id)
set seed 42
ddml init partial if sample_hc==1, foldvar(m0_fid_1) mname(hca) prefix tabfold
ddml E[D|X], mname(hca): pystacked $D $X, type(reg) method(rf)
ddml E[Y|X], mname(hca): pystacked $M $X, type(reg) method(rf)
ddml crossfit, mname(hca)
ddml estimate, mname(hca) cluster(id)
set seed 42
ddml init partial if sample_hc==1, foldvar(m0_fid_1) mname(hcb) prefix tabfold
ddml E[Y|X], mname(hcb): pystacked $Y $X, type(reg) method(rf)
ddml E[D|X], mname(hcb): pystacked $D $X, type(reg) method(rf)
ddml E[D|X], mname(hcb): pystacked $M $X, type(reg) method(rf)
ddml crossfit, mname(hcb)
ddml estimate, mname(hcb) cluster(id)
ddml estimate, mname(m0) replay
ddml estimate, mname(hca) replay
ddml estimate, mname(hcb) replay
restore

* =========================================================
* Table 9: Subgroup estimates and formal interactions
preserve
* Reset model variables for this section (global macros are not restored by restore).
global Y gi
global D dt
global X size lev tobinq roa growth dual i.year
global Xbase $X
foreach model in sg_ht1 sg_ht0 sg_carbon1 sg_carbon0 sg_digital1 sg_digital0 pool_ht pool_carbon pool_digital {
    capture ddml drop, mname(`model')
}
assert inlist(technicalattribute,0,1) if !missing(technicalattribute)
assert inlist(carbonemissions,0,1) if !missing(carbonemissions)
assert inlist(industrydigitalization,0,1) if !missing(industrydigitalization)
set seed 42
ddml init partial if technicalattribute == 1, mname(sg_ht1) prefix kfolds(5) fcluster(id) tabfold
ddml E[Y|X], mname(sg_ht1): pystacked $Y $Xbase, type(reg) method(rf)
ddml E[D|X], mname(sg_ht1): pystacked $D $Xbase, type(reg) method(rf)
ddml crossfit, mname(sg_ht1)
ddml estimate, mname(sg_ht1) cluster(id)
estimates store DML_HighTech
lincom $D
set seed 42
ddml init partial if technicalattribute == 0, mname(sg_ht0) prefix kfolds(5) fcluster(id) tabfold
ddml E[Y|X], mname(sg_ht0): pystacked $Y $Xbase, type(reg) method(rf)
ddml E[D|X], mname(sg_ht0): pystacked $D $Xbase, type(reg) method(rf)
ddml crossfit, mname(sg_ht0)
ddml estimate, mname(sg_ht0) cluster(id)
estimates store DML_NonHighTech
lincom $D
set seed 42
ddml init partial if carbonemissions == 1, mname(sg_carbon1) prefix kfolds(5) fcluster(id) tabfold
ddml E[Y|X], mname(sg_carbon1): pystacked $Y $Xbase, type(reg) method(rf)
ddml E[D|X], mname(sg_carbon1): pystacked $D $Xbase, type(reg) method(rf)
ddml crossfit, mname(sg_carbon1)
ddml estimate, mname(sg_carbon1) cluster(id)
estimates store DML_HighCarbon
lincom $D
set seed 42
ddml init partial if carbonemissions == 0, mname(sg_carbon0) prefix kfolds(5) fcluster(id) tabfold
ddml E[Y|X], mname(sg_carbon0): pystacked $Y $Xbase, type(reg) method(rf)
ddml E[D|X], mname(sg_carbon0): pystacked $D $Xbase, type(reg) method(rf)
ddml crossfit, mname(sg_carbon0)
ddml estimate, mname(sg_carbon0) cluster(id)
estimates store DML_LowCarbon
lincom $D
set seed 42
ddml init partial if industrydigitalization == 1, mname(sg_digital1) prefix kfolds(5) fcluster(id) tabfold
ddml E[Y|X], mname(sg_digital1): pystacked $Y $Xbase, type(reg) method(rf)
ddml E[D|X], mname(sg_digital1): pystacked $D $Xbase, type(reg) method(rf)
ddml crossfit, mname(sg_digital1)
ddml estimate, mname(sg_digital1) cluster(id)
estimates store DML_HighDigital
lincom $D
set seed 42
ddml init partial if industrydigitalization == 0, mname(sg_digital0) prefix kfolds(5) fcluster(id) tabfold
ddml E[Y|X], mname(sg_digital0): pystacked $Y $Xbase, type(reg) method(rf)
ddml E[D|X], mname(sg_digital0): pystacked $D $Xbase, type(reg) method(rf)
ddml crossfit, mname(sg_digital0)
ddml estimate, mname(sg_digital0) cluster(id)
estimates store DML_LowDigital
lincom $D
gen double DT_HT = dt * technicalattribute if !missing(dt,technicalattribute)
global X_HT $Xbase technicalattribute
set seed 42
ddml init partial, mname(pool_ht) prefix kfolds(5) fcluster(id) tabfold
ddml E[Y|X], mname(pool_ht): pystacked $Y $X_HT, type(reg) method(rf)
ddml E[D|X], mname(pool_ht): pystacked $D $X_HT, type(reg) method(rf)
ddml E[D|X], mname(pool_ht): pystacked DT_HT $X_HT, type(reg) method(rf)
ddml crossfit, mname(pool_ht)
ddml estimate, mname(pool_ht) cluster(id)
estimates store DML_HT_interaction
test DT_HT = 0
lincom DT_HT
lincom $D
lincom $D + DT_HT
gen double DT_Carbon = dt * carbonemissions if !missing(dt,carbonemissions)
global X_Carbon $Xbase carbonemissions
set seed 42
ddml init partial, mname(pool_carbon) prefix kfolds(5) fcluster(id) tabfold
ddml E[Y|X], mname(pool_carbon): pystacked $Y $X_Carbon, type(reg) method(rf)
ddml E[D|X], mname(pool_carbon): pystacked $D $X_Carbon, type(reg) method(rf)
ddml E[D|X], mname(pool_carbon): pystacked DT_Carbon $X_Carbon, type(reg) method(rf)
ddml crossfit, mname(pool_carbon)
ddml estimate, mname(pool_carbon) cluster(id)
estimates store DML_Carbon_interaction
test DT_Carbon = 0
lincom DT_Carbon
lincom $D
lincom $D + DT_Carbon
gen double DT_Digital = dt * industrydigitalization if !missing(dt,industrydigitalization)
global X_Digital $Xbase industrydigitalization
set seed 42
ddml init partial, mname(pool_digital) prefix kfolds(5) fcluster(id) tabfold
ddml E[Y|X], mname(pool_digital): pystacked $Y $X_Digital, type(reg) method(rf)
ddml E[D|X], mname(pool_digital): pystacked $D $X_Digital, type(reg) method(rf)
ddml E[D|X], mname(pool_digital): pystacked DT_Digital $X_Digital, type(reg) method(rf)
ddml crossfit, mname(pool_digital)
ddml estimate, mname(pool_digital) cluster(id)
estimates store DML_Digital_interaction
test DT_Digital = 0
lincom DT_Digital
lincom $D
lincom $D + DT_Digital
estimates table DML_HighTech DML_NonHighTech DML_HighCarbon DML_LowCarbon DML_HighDigital DML_LowDigital, b(%9.4f) se(%9.4f) stats(N)
estimates restore DML_HT_interaction
test DT_HT = 0
lincom DT_HT
estimates restore DML_Carbon_interaction
test DT_Carbon = 0
lincom DT_Carbon
estimates restore DML_Digital_interaction
test DT_Digital = 0
lincom DT_Digital
restore

* =========================================================
* Table 10: Extended innovation outcomes
preserve
* Reset model variables for this section (global macros are not restored by restore).
global Y gi
global D dt
global X size lev tobinq roa growth dual i.year
foreach model in extgip extgump exttpa extngpa {
    capture ddml drop, mname(`model')
}
global Y gip
set seed 42
ddml init partial, mname(extgip) prefix kfolds(5) fcluster(id) tabfold
ddml E[D|X], mname(extgip): pystacked $D $X, type(reg) method(rf)
ddml E[Y|X], mname(extgip): pystacked $Y $X, type(reg) method(rf)
ddml crossfit, mname(extgip)
ddml estimate, mname(extgip) cluster(id)
estimates store DML_GIP
global Y gump
set seed 42
ddml init partial, mname(extgump) prefix kfolds(5) fcluster(id) tabfold
ddml E[D|X], mname(extgump): pystacked $D $X, type(reg) method(rf)
ddml E[Y|X], mname(extgump): pystacked $Y $X, type(reg) method(rf)
ddml crossfit, mname(extgump)
ddml estimate, mname(extgump) cluster(id)
estimates store DML_GUMP
global Y tpa
set seed 42
ddml init partial, mname(exttpa) prefix kfolds(5) fcluster(id) tabfold
ddml E[D|X], mname(exttpa): pystacked $D $X, type(reg) method(rf)
ddml E[Y|X], mname(exttpa): pystacked $Y $X, type(reg) method(rf)
ddml crossfit, mname(exttpa)
ddml estimate, mname(exttpa) cluster(id)
estimates store DML_TPA
global Y ngpa
set seed 42
ddml init partial, mname(extngpa) prefix kfolds(5) fcluster(id) tabfold
ddml E[D|X], mname(extngpa): pystacked $D $X, type(reg) method(rf)
ddml E[Y|X], mname(extngpa): pystacked $Y $X, type(reg) method(rf)
ddml crossfit, mname(extngpa)
ddml estimate, mname(extngpa) cluster(id)
estimates store DML_NGPA
display "Outcome 1: Green invention patent applications (GIP)"
ddml estimate, mname(extgip) replay
display "Outcome 2: Green utility-model patent applications (GUMP)"
ddml estimate, mname(extgump) replay
display "Outcome 3: Total patent applications (TPA)"
ddml estimate, mname(exttpa) replay
display "Outcome 4: Non-green patent applications (NGPA)"
ddml estimate, mname(extngpa) replay
restore
global Y gi


* End: all isolated data changes are undone by restore.
* Return default variable macros for optional manual checks.
global Y gi
global D dt
