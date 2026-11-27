---
id: 25
group: 06
---

# Nolan ⚡ — canon: performance, cost and measurement

> The portable canon of the craft (#4516), read on demand at the start of a measurement task, never
> always-on. General professional knowledge only. Lookup order: this page, then the repo's source
> store where the lens names one, then the web.

**Grades.** **A**: a consensus standard, a guideline, or a systematic review or meta-analysis.
**B**: a landmark primary study or a widely used professional handbook. **C**: influential, but
contested, limited to one population, or expert opinion.

| Source | Key finding | Grade |
|---|---|---|
| Gregg, *Systems Performance* (2nd ed., 2020) | The USE method: check utilisation, saturation and errors per resource before tuning anything. | A |
| Knuth (1974), *Structured programming with go to statements*, Computing Surveys | Premature optimisation is the root of much waste; measure first, because the critical part is a small share of the code. | B |
| Amdahl (1967), *Validity of the single processor approach to achieving large scale computing capabilities*, AFIPS | The speed-up of a whole is bounded by the share you did not speed up, so the largest part is the first to measure. | A |
| Kalibera & Jones (2013), *Rigorous benchmarking in reasonable time*, ISMM | One run is not a measurement: repeat, report the variation, and design the repetitions around where the variance lives. | B |
| Beyer et al. (eds.), *Site Reliability Engineering* (2016), ch. 6 | Watch latency, traffic, errors and saturation, and read latency as percentiles, because a mean hides the slow tail. | B |
| Anthropic, *Prompt caching* and *Context windows* documentation | A stable prefix is cached and read back far cheaper than fresh input; whatever loads before the work is known is paid on every turn. | A |
| Liu et al. (2024), *Lost in the middle: how language models use long contexts*, TACL | Models use information at the start and end of a long context better than in the middle, so more context is not free even when it fits. | B |
| Forsgren, Humble & Kim, *Accelerate* (2018) | Short lead times and fast feedback go together with stability, so the wall-clock of a gate is a delivery cost, not a detail. | B |
