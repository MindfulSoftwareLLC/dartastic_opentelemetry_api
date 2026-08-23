# Semantic-convention candidates

Where non-registry attribute keys live, why, and what happens to each.

## The two halves of `lib/src/api/semantics/`

| | `semconv/` | `candidates/` |
|---|---|---|
| Source | OTel Weaver, from the registry | hand-maintained |
| Regenerated | wholesale — `generate.sh` deletes the dir first | never |
| Stability | follows the registry's own stability | **unstable, no deprecation cycle** |
| Promise | this is a published OpenTelemetry convention | this is a proposal we are prototyping |

Nothing hand-written can survive in `semconv/`. More importantly, a consumer
has to be able to tell the two apart, because they carry very different
promises.

## The contract for a candidate

Every key in `candidates/` may be renamed, retyped or removed in a minor
release, without deprecation, the moment upstream reaches a different
conclusion. Each is marked `@experimental`.

When a candidate is **accepted** upstream it is deleted from `candidates/` and
reappears in the generated `semconv/` output on the next regeneration. That
move is the signal that it became real. When one is **rejected**, it is deleted
and the reason is recorded below.

## Why they use registry namespaces

Candidates sit in `app.*`, `device.*` and `browser.*` — namespaces the registry
owns. The OTel naming rules advise against that:

> It is not recommended to use existing OpenTelemetry semantic convention
> namespace as a prefix for a new company- or application-specific attribute
> name. Doing so may result in a name clash in the future.

That rule addresses attributes which will never go upstream, where a vendor
namespace is plainly correct. These are the opposite case. The
semantic-conventions CONTRIBUTING guide asks that "non-trivial changes to
semantic conventions should be prototyped in the corresponding
instrumentation(s)" — and a prototype under a different name proves nothing
about the name. Renaming into a vendor namespace and back would also cost two
wire changes instead of one.

The clash risk is accepted deliberately, and bounded by the contract above.

## Disposition of the 1.0.0-rc.1 removals

1.0.0-rc.1 removed 116 identifiers as "vendor/RUM enums ... not OpenTelemetry
semantic conventions". The registry has since covered a large part of that
surface, so most of them should come back as **registry** conventions rather
than as candidates. This is the full accounting.

### Now in the registry — use these, do not re-add

| Removed | Use instead |
|---|---|
| `session_id` | `session.id` |
| `session.start` | `session.start` (event) |
| `device.id` | `device.id` |
| `device.model` | `device.model.name`, `device.model.identifier` |
| `device.platform` | `os.name` |
| `device.os_version` | `os.version` |
| `app.build_number` | `app.build_id` |
| `app.id`, `app.name`, `app.package_name` | `app.installation.id` for identity |
| `app_lifecycle.state`, `app_lifecycle.changed`, `app_lifecycle.previous_state`, and the six `device.app.lifecycle.*` state values | the `device.app.lifecycle` **event**, with `android.app.state` / `ios.app.state` |
| `jank.count`, `frame.rate`, `frame.time` | `app.jank` event, `app.jank.frame_count`, `app.jank.period`, `app.jank.threshold` |
| `interaction.type`, `user_interaction`, `tap`, `click` | `app.screen.click` / `app.widget.click` events |
| `interaction.target` | `app.widget.id`, `app.widget.name` |
| `view_name`, `view.name`, `navigation.route.name` | `app.screen.name` |
| `view_id`, `navigation.route.id` | `app.screen.id` |
| `crash.*` | `app.crash` event, `app.crash.id` |
| `error.message`, `error.type` | `error.message`, `error.type` |
| `error.stacktrace`, `error.source` | `exception.stacktrace`, `exception.type` |
| `network.type`, `network.connectivity` | `network.type`, `network.connection.state`, `network.connection.subtype` |
| `network.request.duration`, `network.request.url` | `http.client.request.duration`, `url.full` |
| `first.paint`, `first.contentful.paint`, `first_input_delay`, `input.delay`, `time.to.interactive` | `browser.web_vital.*` — `fcp`, `inp`, `ttfb` (web only; see the gap below) |

### Staged here as candidates

| Key | Type | Why the registry needs it |
|---|---|---|
| `app.start.type` (`cold`/`warm`/`hot`) | string | App start is among the most-reported mobile RUM measurements; the registry has nothing for it |
| `app.launch.id` | string | Correlates one launch the way `session.id` correlates one session |
| `app.screen.previous_id`, `app.screen.previous_name` | string | Mirrors `session.previous_id`, which solves the same problem one level up |
| `app.gesture.direction`, `app.gesture.delta.x`, `app.gesture.delta.y` | string, double | The registry describes taps but not directional gestures, a large share of touch interaction |
| `device.battery.level` | double `0..1` | No registry equivalent; `hw.battery.*` describes server inventory, not the running device |
| `device.battery.state` | string | as above |
| `device.battery.save_mode` | boolean | Changes application behaviour the user did not ask for, so it explains performance data that otherwise reads as regression |
| `device.emulator` | boolean | Separating emulator traffic from real-device traffic is a routine analysis need |
| `browser.languages` | string[] | `browser.language` carries only the head of `navigator.languages`; the ordered list is what explains locale behaviour |

### Dropped, and why

| Removed | Reason |
|---|---|
| `browser.vendor` | `navigator.vendor` is a frozen legacy API returning a hardcoded vendor string; `browser.brands` is the registry's structured answer |
| `user_satisfaction_score` | Apdex-style composite scores are a vendor scoring choice, not an observation |
| `action.count`, `interaction.result` | Too vague to specify; no agreed semantics to propose |
| `memory.usage` | Ambiguous between RSS, heap and platform-reported footprint; `system.memory.usage` and `process.memory.usage` already exist server-side, and a mobile proposal needs a precise definition first |
| `render.duration`, `view.duration`, `view_load_time`, `view.start`, `route.transition_duration`, `route.previous_route_duration`, `session.duration`, `navigation.timestamp`, `app_lifecycle.duration`, `app_lifecycle.timestamp` | Durations and timestamps belong in a span's own timing or in a metric instrument, not in an attribute. If they are wanted as instruments they should be proposed as metrics, which this file does not cover |
| `navigation.trigger`, `navigation.action`, and the `push`/`pop`/`replace`/`remove`/`deep_link`/`return_to` values | Framework-specific navigator vocabulary; not portable across platforms |
| `list_selection`, `list_selected_index`, `menu_select`, `menu_selected_item`, `form_submit`, `text_input`, `keydown`, `keyup`, `focus_change`, `scroll`, `swipe`, `drag`, `long_press` | Widget-level interaction vocabulary; the registry's direction is `app.widget.*` plus an event name, not one attribute per gesture |

## Known gaps worth raising upstream

- **`browser.mobile` and `browser.brands` are Chromium-only.** Both are sourced
  from UA Client Hints, which WebKit and Gecko do not implement, and
  `browser.mobile`'s note says to leave it unset when unavailable. A conforming
  implementation therefore omits them for roughly a fifth of the web —
  disproportionately the mobile traffic the attribute exists to find. Note the
  registry is already inconsistent here: `browser.platform` sanctions a legacy
  `navigator.platform` fallback and `browser.mobile` does not.

- **Web vitals have no mobile counterpart.** `browser.web_vital.*` covers the
  web well. There is no equivalent vocabulary for first frame, first
  interaction or time-to-interactive on a native application, which is why
  several rc.1 removals map to "web only" above.
