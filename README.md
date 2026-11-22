# Does a Bad Monsoon Raise Food Prices?
### AccioJob | Spin Build Pitch | Data Analytics Project DA-06

## 1. Project Overview

This project investigates whether rainfall deviations are associated with food inflation across Indian states and whether these relationships appear immediately or after a delay of up to six months.

**Stakeholder:** Food Company Procurement Team

**Business Question:** Can rainfall patterns help procurement teams decide when to purchase and store ingredients before potential food price increases?

## 2. Tools and Technologies

- Microsoft Excel — Data preparation and validation
- MySQL Workbench — Data cleaning, transformation, joins and correlation analysis
- Power BI — Interactive dashboard and data visualization

## 3. Data Sources

**Rainfall Data:** India Meteorological Department (IMD)

Historical monthly rainfall dataset covering 1901–2017 across 36 meteorological subdivisions.

**Food Inflation Data:** Ministry of Statistics and Programme Implementation (MoSPI)

Monthly CPI data for 2014–2017, including vegetables, pulses and cereals.

Official source websites:

- IMD: https://mausam.imd.gov.in/
- MoSPI: https://mospi.gov.in/
- Government Open Data Portal: https://data.gov.in/

*Note: These are official source portals. Exact dataset download links should be added from the original downloaded files.*

## 4. Data Preparation and Cleaning

### Rainfall Data

1. Imported historical rainfall data.
2. Converted monthly rainfall columns into a row-based format.
3. Standardized year, month, subdivision and rainfall fields.
4. Excluded 70 missing rainfall observations from the historical dataset.
5. Calculated historical monthly rainfall baselines using 1901–2013 data.
6. Calculated rainfall deviations from historical monthly averages.

### CPI Data

1. Imported monthly CPI food-category data.
2. Standardized state and month fields.
3. Selected vegetables, pulses and cereals.
4. Restricted the analysis to the common 2014–2017 period.
5. Matched rainfall and CPI records using state and month.

### Matching Results

- 10 matched states/subdivisions
- 1,440 matched state-month-category observations
- 7 lag scenarios (0–6 months)
- 10,080 state-month-category-lag records

**Important:** Exact-name matching does not guarantee that meteorological subdivisions and administrative states have identical geographic boundaries.

## 5. SQL Analysis

MySQL was used to:

- Calculate historical monthly rainfall averages.
- Derive rainfall deviation measures.
- Join rainfall and CPI observations by state and month.
- Generate lagged comparisons from 0 to 6 months.
- Calculate Pearson correlation coefficients.
- Store 21 category-lag correlation results in the `lag_correlations` table.

The analysis compares three food categories across seven lag scenarios.

## 6. Power BI Dashboard

**Dashboard Title:** Does a Bad Monsoon Raise Food Prices?

The dashboard includes:

1. Rainfall vs Food Inflation — Correlation by Lag (0–6 Months)
2. Monthly Food Inflation Trends (2014–2017)
3. Monthly Rainfall Deviation (2014–2017)
4. State and food-category slicers

The correlation chart displays the precomputed overall SQL correlation results. Its values are not dynamically recalculated by the state and category slicers.

## 7. Key Findings

| Food Category | Strongest Absolute-Correlation Lag | Pearson Correlation |
|---|---|---|
| Vegetables | 0 months | +0.1395 |
| Cereals | 0 months | +0.0624 |
| Pulses | 3 months | −0.0305 |

### Interpretation

- Vegetables show the highest observed absolute correlation, but the relationship remains very weak.
- Cereals show almost no linear relationship.
- Pulses show virtually no linear relationship, even at their strongest observed lag.

The results do not establish that below-normal rainfall causes subsequent food inflation.

## 8. Business Recommendation

Rainfall deviations should not be used as the sole signal for purchasing or storing food ingredients.

Procurement teams should combine rainfall monitoring with market prices, inventory requirements, supplier information and other supply-chain indicators.

## 9. Limitations

- CPI data covers four years rather than approximately ten years.
- Geographic matching is limited to 10 exact-name state/subdivision pairs.
- Historical rainfall data contains missing observations.
- Other economic and supply-chain factors were not controlled for.
- Correlation does not establish causation or forecasting accuracy.

## 10. Conclusion

The analysis found very weak correlations between rainfall deviations and food inflation across vegetables, pulses and cereals.

Rainfall may provide useful context, but the available evidence does not support using it as a standalone procurement timing signal.

## 11. Project Deliverables

- Power BI dashboard (`.pbix`)
- Data preparation and SQL analysis
- One-page insight memo
- Two-minute project presentation

**Project:** AccioJob Spin Build Pitch — DA-06
