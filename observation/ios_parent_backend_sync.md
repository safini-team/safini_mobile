# iOS parent/backend sync

The previous proposal to apply every catalog rule to one combined selection has
been superseded. Each rule is now linked to its own locally selected app token.
See [the implementation](ios_screen_time_impl.md) and
[release verification](ios_screen_time_review.md).

The API stores operational status and Safini-authored policy only. Usage reports
stay inside Apple's report extension. An API status update contains no tokens,
app identities, durations, or report-derived analytics.
