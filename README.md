# GNSS-Driven-Atmospheric-Sensing-for-Hurricane-Trajectory-Estimation Using Zenith Wet Delay (ZWD)

## Overview

This project investigates how GNSS (Global Navigation Satellite System) data can be used to analyze and track tropical cyclones. The focus is on understanding how atmospheric moisture and ground movement change during hurricanes, and whether these signals can be used to estimate storm behavior such as position, speed, and direction.

The study is based on two major hurricanes that impacted Florida in 2024. By analyzing GNSS-derived parameters, the project explores how storms interact with the atmosphere and the Earth's surface.

## Data

The data comes from permanent GNSS stations across Florida, part of the Florida Permanent Reference Network (FPRN), provided by the Florida Department of Transportation (FDOT).

A total of around 17 stations are used, distributed across western, central, and eastern Florida to capture the storm progression geographically.

Each dataset consists of time-series data sampled every 30 seconds, covering several days before, during, and after each storm event.

The main variables used are:

* **Zenith Wet Delay (ZWD):** represents the delay of GNSS signals caused by water vapor in the atmosphere. This is the key variable for detecting storm-related moisture changes.
* **Station height (vertical position):** used to detect land subsidence and deformation caused by flooding and pressure changes.
* **Kinematic position data:** provides high-resolution station movement over time.
* **Water level measurements:** used to validate GNSS-derived height changes.

## Methods

### GNSS Processing

Raw GNSS observations are processed using PPP-AR (Precise Point Positioning with Ambiguity Resolution). This method provides high-precision positioning and estimates atmospheric delays by correcting for satellite errors, clock drift, and signal propagation effects.

### Time-Series Analysis

The extracted ZWD and height data are analyzed in MATLAB. A moving average is applied to reduce noise, and time-series plots are used to identify peaks and irregularities associated with storm activity. Data from multiple stations is compared to observe how the storm evolves spatially.

### Wavelet Analysis (CWT)

The Continuous Wavelet Transform (CWT) is used to analyze non-stationary behavior in the data. Unlike standard frequency methods, wavelets allow detection of short-term changes in both time and frequency.

In this project, CWT is used to:

* Detect sudden increases in atmospheric moisture
* Identify the timing of storm passage
* Highlight anomalies in both ZWD and height data

This makes it possible to clearly observe when the storm impacts different locations.

### Land Subsidence

Station height variations are analyzed to study how the ground responds to storm conditions. These variations are compared with nearby water level data to verify whether observed changes are related to flooding or storm load effects.

### Storm Tracking

Storm movement is estimated by comparing signals between stations:

* Cross-correlation is used to find time delays between similar patterns
* Speed is calculated using distance divided by time delay
* Direction is inferred from which stations show peak ZWD first

## Results

The analysis shows that:

* ZWD increases significantly during storms, reflecting rising atmospheric moisture
* Height data shows clear changes during landfall, indicating ground response
* Combining ZWD and height gives a more reliable way to track storms
* It is possible to estimate storm speed and direction, although accuracy depends on station coverage and data quality

## Tools

MATLAB, PRIDE PPP-AR, Wavelet Transform

