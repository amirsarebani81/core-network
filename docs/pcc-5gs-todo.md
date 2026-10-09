# To do: Policy and Charging for 5GS

The Policy and Charging Control part (`chapters/pcc/`) has a Principles
chapter and a chapter for GPRS and the EPC. A third chapter, for the 5GS
(TS 23.503), waits until the 5GC part describes the network functions
(so far it has only the architecture figure), because it assumes that
the reader already knows the SMF and the AMF. Delete this file when that
chapter is written.

## Outline

This outline was drafted before the research for the other chapters, so
verify every item against the specifications in `../docs/txt` before you
use it.

- Architecture: the PCF, SMF, UPF, AMF, AF, NEF, UDR, and CHF, and the N7,
  N5, N15, N28, N30, N36, and N40 reference points (TS 23.503 clause 5).
- Services: `Npcf_SMPolicyControl`, `Npcf_PolicyAuthorization`,
  `Npcf_AMPolicyControl`, `Npcf_UEPolicyControl`, `Nchf_ConvergedCharging`,
  and `Nchf_SpendingLimitControl`.
- Procedures, each with a call flow:
  - establishment, modification, and termination of an SM Policy
    Association;
  - an AM Policy Association;
  - URSP delivery;
  - a converged charging session.
- EPC interworking: a combined SMF+PGW-C talks to a combined PCF+PCRF over
  N7 instead of Gx. This is where the 5GS chapter connects to the GPRS and
  EPC chapter.

## Decisions to keep

- Create the chapter in `chapters/pcc/5gs/` and add its `include::` line
  after the GPRS and EPC chapter in the Policy and Charging Control part
  of `main.adoc`. That part stays after all the generation parts, so it is
  renumbered when the 5GC part is added; prose refers to it only through
  `<<_policy_and_charging_control>>`.
- Describe the HTTP/2 service-based interfaces in a protocol chapter of the
  5GC part, not in the Policy and Charging Control part, in the same way as
  Diameter lives in `chapters/epc/diameter.adoc`.
- Use the real 3GPP names, for example "the PCRF or the PCF", and invent no
  neutral terms.
- Draw one call flow per procedure.
- Recheck the 5GS column of the comparison table in
  `chapters/pcc/common/policy-decision-and-enforcement.adoc` and the 5GS
  paragraphs of the other Principles pages when the chapter is written.
- Out of scope, as for the EPC: MBMS policy and the roaming reference
  points.
