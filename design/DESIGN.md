# Mirra - Design System

AI before/after preview app for aesthetic clinics, salons and med-spas. Bright, calm, clinical-but-warm. Light theme.

## Color (use ONLY these colors; no default violet or indigo, no flat neutral grey)
- Background: #F4FCF9 (mint-tinted near-white)
- Surface (cards, sheets): #FFFFFF
- Surface alt (grouped rows): #EAF6F0
- Accent (large fills, icons, hero numerals): #10A56A
- Accent fill (any button or chip with a WHITE label): #0D7C50, pressed #0B734A, disabled #B9DCCB
- Accent tint (selected chips, badges): #E2F4EC with #0D7C50 text
- Support (illustration, secondary data, soft gradient end): #F59BD0 blush pink; data series #F555B4
- Text primary #0C1F18, secondary #46594F, tertiary #67776D
- Border hairline #DCEAE3, input / control border #6DA074
- Status: success #0E7C3A on #E3F4E9, warning #AA4F09 on #F6EAE1, danger #CE2020 on #FBE5E5, info #0D774D on #E2EFEA
- Hero gradient behind WHITE text: #0D7C50 -> #0B734A. The soft accent -> blush blend is decoration only, never behind text.

## Typography
- UI + body: Public Sans. Display / screen titles / hero numerals: Spectral (serif).
- Display 32 / 700 / -0.02em, Title 20 / 600, Body 16 / 400, Label 14 / 500, Caption 13 / 500.
- Minimum text 12px (13px chips and tags, 14px safety, consent or legal text). Use only these 5 sizes.

## Frame + safe areas
393x852 mobile. Keep top ~59px and bottom ~34px clear of tappable content. Screen edge padding 20px, 8pt spacing scale.

## Shape + elevation
Card radius 20, control 14, input 12, pill 999. Soft shadow only: 0 1px 2px rgba(12,31,24,.04) + 0 8px 24px rgba(12,31,24,.06).

## Icons
One set only: rounded outline (Lucide style), 24px, 1.75 stroke. Never mix filled and outline.

## Controls (one spec, reused on every screen)
- Primary button: pill 52px, #0D7C50 fill, white Public Sans 16/600 label.
- Secondary button: pill, white fill, 1.5px #0D7C50 border, #0D7C50 label.
- Destructive secondary: white fill, 1.5px #CE2020 border, #CE2020 label.
- Text input: 12px radius, 1px #6DA074 border, white fill, focus 2px #10A56A ring, error #CE2020 border + helper.
- Card: 20px radius white with soft shadow.
- Chip: pill 34px; selected #E2F4EC fill + #0D7C50 label; unselected white + #DCEAE3 border.
- Slider: #10A56A track, white 24px thumb with soft shadow.

## Shared components
- Bottom tab bar (exactly 4 tabs, this order): Studio (sparkles), History (images), Clinic (building-2), Account (user-round). Flat white bar, hairline top border, 24px outline icons, 12px labels. Active tab: #0D7C50 icon + label with a small #E2F4EC pill behind the icon. Inactive: #67776D. Never rename, reorder, add or remove tabs.
- Header: screen title left in Spectral 26/600, 36px round real photo avatar right.
- AI label: every AI-generated image has a small dark translucent pill bottom-left with sparkles icon + "AI simulation" in white 12px. Never removed.
- Disclaimer line under every result: info icon + "AI-generated simulation, not a guaranteed medical outcome." 14px #46594F.

## Imagery
Real photography only: diverse adult women and men, bright minimal clinic and salon interiors, soft daylight, mint and blush accents. Empty states and onboarding also use real photos or flat 2D vector art. NO 3D renders, claymorphism, isometric, CGI or glossy plastic objects.

## Focal element
Each screen has ONE bold focal element (hero photo card, big Spectral numeral, or the before/after image) that owns the visual weight. Everything else stays quiet.

## Meaning of color
Red only for errors and destructive actions (delete, cancel subscription). Warnings and the medical disclaimer card use the warning status color with an icon.

## Copy scope
Do not mention: guaranteed result, diagnosis, body contouring, breast, surgery, prescription, insurance. No invented integrations or person names beyond: Noa Levi, Maya Cohen, Yael Mizrahi, Tamar Ben-David, Lumiere Aesthetic Clinic - Tel Aviv. Currency ILS.

## RTL
App ships Hebrew + English. Layouts mirror for Hebrew (RTL); keep icons directional-safe.
