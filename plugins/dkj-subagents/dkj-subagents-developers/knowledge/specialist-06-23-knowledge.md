---
id: 23
group: 06
---

# Sebastian 🛡️ — canon: application security and privacy

> The portable canon of the craft (#4516), read on demand at the start of a security task, never
> always-on. General professional knowledge only. Lookup order: this page, then the repo's source
> store where the lens names one, then the web.

**Grades.** **A**: a consensus standard, a guideline, or a systematic review or meta-analysis.
**B**: a landmark primary study or a widely used professional handbook. **C**: influential, but
contested, limited to one population, or expert opinion.

| Source | Key finding | Grade |
|---|---|---|
| Saltzer & Schroeder (1975), *The protection of information in computer systems*, Proceedings of the IEEE | Least privilege, fail-safe defaults, complete mediation and economy of mechanism still frame most design reviews. | A |
| OWASP, *Top 10* (2021) | Broken access control is the most common web risk; injection, insecure design and misconfiguration follow. | A |
| OWASP, *Top 10 for LLM Applications* (2025) | Prompt injection ranks first: text an LLM reads can act as instructions, so untrusted content is data, never a command. | A |
| Greshake et al. (2023), *Not what you've signed up for: compromising real-world LLM-integrated applications with indirect prompt injection*, AISec | Instructions planted in a web page, file or issue an agent reads can steer it; a tool-using agent turns that into actions. | B |
| MITRE, *CWE Top 25 Most Dangerous Software Weaknesses* (yearly) | The weaknesses behind most real CVEs, ranked by frequency and severity; the vocabulary a finding is named in. | A |
| NIST SP 800-218, *Secure Software Development Framework* 1.1 (2022) | Secure development as practices: protect the software, produce well-secured software, respond to vulnerabilities. | A |
| Regulation (EU) 2016/679 (GDPR), articles 5, 25 and 32 | Data minimisation and purpose limitation, privacy by design and by default, and security proportionate to the risk. | A |
| Shostack, *Threat Modeling: Designing for Security* (2014) | Ask what you are building, what can go wrong (STRIDE), what you will do about it, and whether you did a good job. | B |
