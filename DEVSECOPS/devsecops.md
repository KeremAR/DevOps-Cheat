# DEVSECOPS

## What is Shift Left Testing?

Shift-left testing is a method where testing begins early in the development process, often before any code is written, instead of waiting until the final stages.

### Benefits of Shift Left Testing
* **Early defect detection:** Find problems before they affect development or increase in complexity.
* **Reduced costs:** Fix issues early when they are cheaper and easier to resolve.
* **Better team collaboration:** Encourage closer teamwork between developers and testers from the start.
* **Faster time to market:** Deliver products quicker by addressing issues early and reducing delays.

---

## Example DevSecOps Pipeline Stages

**1. Stage: Static Analysis (Pre-Build)**
* `Secret Scan` (Trivy fs)
* `SCA - Dependency Scan` (Trivy fs)
* `IaC Scan` (Trivy fs)
* `SAST` (SonarQube)

**2. Stage: Build**
* Code is compiled, `docker build` is run.

**3. Stage: Artifact Scan (Post-Build)**
* `SCA - Image Scan` (Trivy image)
* `SBOM Creation` (Trivy image --format cyclonedx)

**4. Stage: Deploy to Staging**
* The application is deployed to a test (staging) environment.

**5. Stage: Dynamic Analysis (Test)**
* `DAST` (OWASP ZAP) - Run against the *running* staging application.

**6. Stage: Deploy to Production**
* If all checks pass, deploy to production.

---

## OWASP Top 10 (2021)

OWASP Top 10 is considered the "minimum security standard" for a web application.

### A01: Broken Access Control
* **What is it?** When users can access data or functions they are not authorized for (e.g., changing `.../user/123/profile` to `.../user/124/profile` to see another user's profile).
* **Pipeline Control:** One of the most difficult to automate.
    * **DAST (OWASP ZAP):** Yes. It can find this vulnerability by testing the running application.

### A02: Cryptographic Failures
* **What is it?** Storing sensitive data (passwords, credit card info) without encryption, or using weak/old encryption algorithms (e.g., MD5).
* **Pipeline Control:**
    * **SAST (SonarQube):** Yes. It is very good at finding things like "MD5 usage" or "hardcoded passwords" in the code.
    * **Secret Scan (Trivy):** Yes. It directly contributes by finding API keys and passwords embedded in the code.

### A03: Injection
* **What is it?** When untrusted data from a user is sent to the server as part of a command (SQL, OS, LDAP). (The most famous is SQL Injection).
* **Pipeline Control:**
    * **SAST (SonarQube):** Yes. This is where SAST tools shine. They find patterns like "user input goes directly to a database query."
    * **DAST (OWASP ZAP):** Yes. It attempts to send SQL injection queries to the live application.

### A04: Insecure Design
* **What is it?** This isn't a coding bug, but rather an insecure design of the application's architecture from the start (e.g., an easily predictable password reset mechanism).
* **Pipeline Control:** Almost impossible. This is not something a tool in a pipeline can find. It is solved with manual "Threat Modeling."

### A05: Security Misconfiguration
* **What is it?** Not changing default passwords, leaking sensitive information in error messages, making S3 buckets public, running containers as root.
* **Pipeline Control:**
    * **IaC Scan (Trivy):** Yes. This is the primary purpose of Trivy's IaC scan. It scans `Dockerfile` and `k8s.yaml` files for exactly this.
    * **SAST (SonarQube):** Yes. The "Security Hotspot" section looks for vulnerabilities in application configuration files (`web.xml`, etc.).

### A06: Vulnerable and Outdated Components
* **What is it?** Using 3rd-party libraries (Log4j, React, Flask) in your project that have known vulnerabilities (CVEs).
* **Pipeline Control:**
    * **SCA (Trivy Dependency Scan):** Yes. This is exactly what Trivy's "dependency scan" feature does.
    * **Image Scan (Trivy Image Scan):** Yes. It also scans the OS packages (openssl, curl) within the container image under this category.

### A07: Identification and Authentication Failures
* **What is it?** Weak password policies, improper session management, lack of protection against "brute force" attacks.
* **Pipeline Control:**
    * **DAST (OWASP ZAP):** Yes. It can test these vulnerabilities by attacking the live application's login form.

### A08: Software and Data Integrity Failures
* **What is it?** Using data or code from an untrusted source without verification (e.g., a CI/CD pipeline pulling a package without checking its signature, Insecure Deserialization).
* **Pipeline Control:**
    * **SAST (SonarQube):** Yes. It is very good at finding "Insecure Deserialization" vulnerabilities.
    * **Pipeline Security:** (This is more of a process) Verifying image signatures (like with Cosign) falls into this category.

### A09: Security Logging and Monitoring Failures
* **What is it?** Critical security events like failed login attempts or unauthorized access attempts are not logged at all, or if logged, no one monitors them.
* **Pipeline Control:** Very difficult.
    * **Note:** This category is more concerned with *runtime* security (Are your Grafana, Loki, SIEM systems working correctly?).

### A10: Server-Side Request Forgery (SSRF)
* **What is it?** When an attacker can force the server to make requests on its behalf (and with its IP) to another server on the "internal network" (database, admin panel).
* **Pipeline Control:**
    * **SAST (SonarQube):** Yes. SAST can detect this vulnerability very well by finding "a URL from a user being used directly in an HTTP request."
    * **DAST (OWASP ZAP):** Yes. It can test this live.

---

## What is SAST? (Static Application Security Testing)

Its fundamental philosophy is: **"To find security vulnerabilities by reading the application's source code, line by line, without ever running it."**

There are 3 key terms to understand SAST:
* **Static:** Your code is analyzed while it is *not running* (at rest). This is done by reading your `.java`, `.py`, `.js` files directly, even before the code is "built".
* **Application:** SAST focuses on the *primary application code* written by you or your team (unlike SCA, not 3rd-party libraries).
* **Security Testing:** It looks for *logical security vulnerabilities* and *bad coding patterns* within your code.

### SAST Tools Market
**Group 1: Corporate & Platform-Oriented Solutions (Often On-Prem/Hybrid)**
* SonarQube (Enterprise / SonarCloud)
* Checkmarx
* Veracode

**Group 2: Developer-Oriented SaaS Platforms**
* Snyk Code
* GitHub CodeQL (Advanced Security)
* Semgrep

### SonarQube Deep Dive
SonarQube is considered the "gold standard" of the SAST market and goes beyond all the basic requirements of SAST.

We can divide SonarQube's job into two parts:

**A. SAST (The Security Part)**
This is everything SonarQube labels as "Vulnerabilities" and "Security Hotspots".
* **Vulnerabilities:** Exploitable vulnerabilities that are 100% certain (like SQL Injection). This is the main task of SAST.
* **Security Hotspots:** "Suspicious" areas that might not always be a vulnerability, but require a human review (e.g., "You're using a weak random number generator here; if this is for a password, it could be dangerous, please check.").

**B. Code Quality (The Extra Feature)**
This is where SonarQube's main reputation comes from. It goes *beyond* SAST to also find:
* **Bugs:** Logical errors that could cause your program to crash (e.g., "This variable might be 'null' and you will get a NullPointerException").
* **Code Smells:** Bad coding habits that make your code hard to read and maintain (e.g., "This function is too long, break it apart").
* **Test Coverage:** Measures what percentage of your code is covered by unit tests.
* **Code Duplication:** Finds identical or very similar blocks of code that have been "copy-pasted" in different parts of your project.

---

## What is SCA (Software Composition Analysis)?
The process of analyzing the components that make up your software, especially third-party packages, to identify risks related to security, licensing, and versioning.

Modern development relies heavily on open-source code. While this accelerates development, it also introduces risks. SCA tools help mitigate these risks by automatically scanning and detecting vulnerable code and dependencies within an application’s codebase.

### How does SCA differ from SAST?
SAST scans your **proprietary code** for bugs and logic flaws.
In contrast, SCA focuses on **third-party and open-source libraries**, flagging known CVEs and license issues that come from dependencies you didn’t write yourself.

### SCA Tools Market
Let's divide these tools into 3 groups (with honorable mention to Trivy and Dependabot):

**Group 1: "The 3 Bigs" (Classic, Corporate Giants)**
* Black Duck
* Sonatype
* Mend

**Group 2: "Modern Leader" (Developer-Focused)**
* Snyk
* Semgrep

**Group 3: "Next Generation" (Focused on Specific Problems)**
* Endor Labs
* Oligo
* Arnica
* Aikido

---

## Trivy Deep Dive (Multi-purpose Scanner)
Trivy does several important things that SAST doesn't look at:

**a. Dependency Scan -> SCA (Software Composition Analysis)**
* Looks for known vulnerabilities (CVEs) in *other people's* (3rd-party) code (Flask, React, Log4j). It reads your `package-lock.json` or `requirements.txt` and says, "The Flask 2.0.0 package you are using has CVE-2023-1234!"

**b. IaC Scan -> Misconfiguration Scanning**
* Looks at the application *infrastructure*. It reads your `Dockerfile` or `k8s.yaml` and says, "This container is running as 'root'!" or "This S3 bucket is set to 'public'!"

**c. Secret Scan -> Secret Scanning**
* Looks for simple but dangerous patterns (regex). It searches your code for text that looks like `ghp_...` (GitHub token) or `AKIA...` (AWS key).

**d. Container Image Scan -> Artifact Scanning**
* Looks at the *compiled product* (image). It scans the OS packages (openssl, curl) inside the image and says, "The `openssl` version in this image has a known CVE!"

**e. License Scanning**
* This is not a *security* scan, but a *legal compliance* scan. Using libraries with "viral" licenses like `GPL` might force you to open-source your *own* code. This scan protects your company from legal and financial risks.

**f. SBOM Creation**
* It creates a complete "ingredients list" of all components and libraries inside your application. This allows us to perform a "retroactive audit" when a problem arises in the future.

---

## What is SBOM? (Software Bill of Materials)
An SBOM is a complete, formal, and machine-readable **inventory** of a codebase, including the open-source components, the license, and version information for those components.

It is the **"ingredients list"** for your software.

### Benefits:
* **Open source versions:** An SBOM provides a list of the exact versions of open-source components in your code.
* **Open source licenses:** An SBOM lists the open-source licenses that govern the components you use, allowing you to assess your legal and IP risk.
* **Vulnerability Management:** An SBOM (the inventory) can be fed into an SCA tool (the analyzer) to *then* quickly identify and assess risks. It allows you to perform "retroactive audits" (e.g., "Are we using the newly discovered vulnerable version of `log4j` in *any* of our 1000 projects?").

### SBOM Tools Market

**Group 1: Focused Open Source Generators**
* Syft (by Anchore)
* CycloneDX CLI
* SPDX CLI

**Group 2: As a Feature of SCA/Security Platforms**
* Trivy
* Mend / Sonatype / Black Duck / Snyk

**Group 3: SBOM Storage and Management Platforms**
* Nexus Repository / Artifactory
* Dependency-Track (by OWASP)

---

## What is Dependabot?
Dependabot is a tool that scans your GitHub projects' dependencies and performs two main jobs:

* **Security Updates (Most Important):** It scans files like `package.json`. If it finds a package with a security vulnerability (CVE), it opens a Pull Request (PR) on your behalf that updates the package version.
* **Version Updates (Optional):** Even if there is no vulnerability, it opens PRs to "stay up-to-date" as new versions of your packages are released.

---

## What is DAST? (Dynamic Application Security Testing)
A security testing method that examines web applications **while they are running**. It simulates attacks, just like a hacker would, to uncover vulnerabilities that might be missed by other methods.

DAST doesn't need access to the source code (**"black-box" testing**), making it ideal for testing applications in production or when source code isn't available.

### How it Works:
1.  **Crawling:** The DAST tool starts by crawling the application, mapping its structure, and identifying all its inputs and outputs.
2.  **Attack Simulation:** The tool then sends a series of requests to the application, testing for common vulnerabilities such as SQL Injection, Cross-Site Scripting (XSS), and Authentication flaws.
3.  **Vulnerability Identification:** The DAST tool analyzes the application's *responses* to these attacks. Unexpected behavior or error messages can indicate potential vulnerabilities.
4.  **Reporting:** Finally, the tool generates a report detailing the identified vulnerabilities.

### DAST Tools Market

**Group 1: The Open Source Standard (and Most Popular)**
* OWASP ZAP

**Group 2: Corporate & Commercial Platforms (SaaS / On-Prem)**
* Burp Suite Enterprise (by PortSwigger)
* Invicti (formerly Netsparker)
* Acunetix

**Group 3: Integrated Platform Add-ons (Alongside SAST/SCA)**
* GitLab Ultimate DAST
* Snyk DAST