# Linux Package Management Script

## Introduction

This Bash script is designed to simplify the process of installing, updating, and removing packages on Linux systems. Whether you're a developer, sysadmin, or a Linux enthusiast, this script aims to streamline your package management tasks.

## Features

### 1. **Installation with Ease**

The script allows you to install packages effortlessly. By reading a CSV file, it identifies packages marked with a "yes" option, checks their status, and either updates or installs them accordingly.

### 2. **Log Tracking**

Keep track of every installation or removal operation with the detailed log file. Stay informed about the script's activity and easily troubleshoot any issues.

### 3. **Package Types**

Filter packages based on their types. This feature is useful for users who want to explore or install packages within a specific category.

### 4. **Error Handling**

The script incorporates robust error handling. If a package installation or removal fails, the script notifies you, ensuring that potential issues are addressed promptly.

## How to Use

### Installation

To install packages marked with a "yes" option in the CSV file, run:

```bash
./script.sh -i

