# Play Console App Content Checklist

This is preparation only. Do not submit answers without checking the current
Play Console wording and the exact final AAB.

| Section | Current evidence / draft response | Action |
| --- | --- | --- |
| App access | All ready functionality is available without sign-in, membership, location, or special credentials. | Select unrestricted access if the current wording matches. |
| Ads | No ad UI, ad SDK, advertising ID permission, or paid placement exists. | Draft: No ads. Verify final dependencies. |
| Privacy policy | Draft exists in `docs/PRIVACY_POLICY_DRAFT.md`; in-app privacy is available from Settings and About. | Add effective date/contact, legal review, host on public HTTPS, then enter URL. |
| Data Safety | No developer collection/sharing; microphone is ephemeral local processing; preferences are local. | Use `docs/data_safety_draft.md`; **VERIFY IN CURRENT PLAY CONSOLE**. |
| Content rating | General guitar/music utility; no sensitive content found. | Complete the current IARC questionnaire using the separate preparation document. |
| Target audience | General-audience utility, not specifically child-directed. Repository recommendation is 13+. | User must choose truthful age bands and review Families implications. |
| Sensitive permissions | `RECORD_AUDIO` is required for the foreground Guitar Tuner. | Ensure store/privacy copy explains tuner use; inspect final manifest. |
| Account deletion | No account creation and no developer-held account data. | Mark not applicable if that is the current form logic. |
| Government affiliation | No government service or affiliation is represented. | Draft: No; **VERIFY IN CURRENT PLAY CONSOLE**. |
| News | The app is not a news or magazine product. | Draft: Not a news app. |
| Health | No medical, health, fitness, diagnosis, or treatment functionality or claims. | Draft: No health features. |
| Financial features | No payments, loans, banking, trading, wallets, crypto, or financial advice. | Draft: No financial features. |
| App category | Music & Audio is the likely category. | User decision in current console. |
| Contact details | No public policy/support contact is resolved in the repository. | **USER INPUT REQUIRED** before submission. |

## Before saving any declaration

- **VERIFY IN CURRENT PLAY CONSOLE** all section names, definitions, and
  required questions.
- Compare the form with the exact AAB, its App Bundle Explorer permission list,
  and its SDK disclosures.
- Do not advertise Coming Soon tools as available.
- Do not claim zero latency, perfect accuracy, certification, or data behavior
  broader than the inspected build.
