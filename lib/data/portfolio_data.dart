/// Anything that can appear as a card in the "My Work" carousel.
///
/// Two kinds live side by side: a [Feature] — a shipped piece of product work
/// with phone-framed media and a full detail page — and a [Post], the lighter
/// card for a hackathon build, a side project or a weekend experiment, where
/// one image and a few lines are the whole story.
abstract class WorkItem {
  /// Stable slug, unique across features *and* posts.
  String get id;
}

/// A single shipped feature shown in the "My Work" showcase. Each entry is one
/// piece of product work (e.g. a recommendation rail), not a whole app.
class Feature implements WorkItem {
  @override
  final String id;
  final String name;

  /// Where the feature was built + the platforms it shipped on, e.g.
  /// "Apna Mart · iOS & Android". Shown as a small line under the name.
  final String context;
  final String tagline;

  /// One-line hook shown on the thumbnail card.
  final String shortDescription;

  /// Full, recruiter-facing write-up shown on the detail page.
  final String description;

  /// What the feature does / what was built — the bullet list on the detail page.
  final List<String> highlights;
  final List<String> techStack;

  /// Poster image for the card (and video fallback). Asset path or http(s) URL.
  final String? thumbnailImage;

  /// Short mp4 that autoplays muted + looping on the card thumbnail.
  /// Asset path or http(s) URL. Optional — falls back to [thumbnailImage].
  final String? previewVideo;

  /// Device-framed media shown on the detail page — each entry becomes its own
  /// phone frame (2-3+ recommended). Mix videos and images freely; each is an
  /// asset path or http(s) URL. Videos autoplay muted + looping; tapping an
  /// image opens a full-screen viewer.
  final List<String> showcase;

  /// Optional link out — a repo, a store listing, a write-up. Shown as a small
  /// action under the tech stack. Company work usually has none; a project of
  /// your own usually does.
  final String? link;

  /// Label for that link, e.g. "see the repo".
  final String linkLabel;

  final String accentColor;

  const Feature({
    required this.id,
    required this.name,
    required this.context,
    required this.tagline,
    required this.shortDescription,
    required this.description,
    required this.highlights,
    required this.techStack,
    this.thumbnailImage,
    this.previewVideo,
    this.showcase = const [],
    this.link,
    this.linkLabel = 'see the repo',
    required this.accentColor,
  });
}

/// A lightweight "here's a thing I built" card — one image and some words.
///
/// Use this for hackathon builds, side projects and weekend experiments: work
/// worth showing that doesn't need screen recordings, a highlight list or a
/// detail page. It renders as a card in the same carousel as [Feature], with
/// the image filling the media well instead of a phone frame. Tapping it opens
/// the image full-screen; if [link] is set, the card also carries a small
/// action that opens the original post (LinkedIn, a repo, a devpost page…).
class Post implements WorkItem {
  @override
  final String id;

  /// The headline — what you built. e.g. "Nyaya Sathi".
  final String title;

  /// The dateline under the title — where and when, e.g.
  /// "HackByte 3.0 · March 2026". Shown in small caps, in the accent colour.
  final String context;

  /// The card's copy — a short paragraph in your own voice, the way you'd
  /// caption the post. Two to four sentences reads best on the card.
  final String body;

  /// The longer write-up on the post's own page. Leave it empty and the page
  /// falls back to [body].
  final String description;

  /// What you actually built — the bullet list under the story.
  final List<String> highlights;

  /// The one image that carries the card. Asset path (e.g.
  /// `assets/images/hackbyte_team.jpg`) or an http(s) URL. Landscape crops
  /// best; portrait works too and is letterboxed on its accent wash.
  final String? image;

  /// The rest of the deck, shown after [image] — slides, photos, anything
  /// worth swiping through on the post's page.
  final List<String> gallery;

  /// Stack / theme stamps along the bottom of the card.
  final List<String> tags;

  /// A photo mounted in the margin of the post's page, below the tags and the
  /// link — where the column would otherwise run out of content. A portrait
  /// shot sits best here; it stays out of the deck.
  final String? sideImage;

  /// Caption printed under [sideImage], in the same small type as a plate
  /// caption in a magazine.
  final String sideCaption;

  /// Optional link to the original post or repo.
  final String? link;

  /// Label for that link, e.g. "Read the post" or "See the repo".
  final String linkLabel;

  final String accentColor;

  const Post({
    required this.id,
    required this.title,
    required this.context,
    required this.body,
    this.description = '',
    this.highlights = const [],
    this.image,
    this.gallery = const [],
    this.tags = const [],
    this.sideImage,
    this.sideCaption = '',
    this.link,
    this.linkLabel = 'read the post',
    required this.accentColor,
  });

  /// The whole deck in order — [image] first, then [gallery].
  List<String> get allImages => [?image, ...gallery];
}

/// Media helpers — every media field accepts either a local asset path
/// (e.g. `assets/videos/app.mp4`) or a remote URL (e.g. `https://.../app.mp4`).
class MediaSource {
  const MediaSource._();

  static bool isNetwork(String path) =>
      path.startsWith('http://') || path.startsWith('https://');

  static bool isVideo(String path) {
    final p = path.toLowerCase().split('?').first;
    return p.endsWith('.mp4') || p.endsWith('.mp4') || p.endsWith('.webm');
  }
}

class Experience {
  final String company;
  final String role;
  final String period;
  final String description;
  final List<String> highlights;

  /// The company's own logo, downloaded into assets. Null falls back to a
  /// monogram tile, so a role without a mark still looks deliberate.
  final String? logoAsset;

  const Experience({
    required this.company,
    required this.role,
    required this.period,
    required this.description,
    required this.highlights,
    this.logoAsset,
  });
}

class Education {
  final String institution;
  final String degree;
  final String period;
  final String detail;

  const Education({
    required this.institution,
    required this.degree,
    required this.period,
    required this.detail,
  });
}

const kFeatures = [
  Feature(
    id: 'welcome-gift',
    name: 'welcome gift',
    context: 'apna mart · ios & android',
    tagline: 'a free gift that turns first-time visitors into first orders',
    shortDescription:
        'new shoppers pick a free welcome gift that unlocks in their cart once '
        'the order crosses a minimum — nudging them to place a first purchase.',
    description:
        'the welcome gift is a growth feature that greets a brand-new shopper with '
        'a free gift they get to choose themselves. they pick it during onboarding, '
        'then it rides along in their cart as a locked reward that unlocks the moment '
        'their order crosses a small minimum value — a gentle nudge to complete that '
        'important first purchase. if the gift they want is out of stock, they can opt '
        'in to be notified when it’s back, so the offer never feels like a dead end. i '
        'built the full experience — the gift selection screen, the locked/unlocked '
        'cart states, promo-video playback for each gift, and the celebration moments '
        'when a gift is picked and added.',
    highlights: [
      'a free gift for new shoppers, chosen during onboarding — a strong reason to '
          'place that first order',
      'locks in the cart and unlocks once the order crosses a minimum value, '
          'nudging a bigger, completed basket',
      'out-of-stock gifts offer a "notify me" opt-in, so the offer never dead-ends',
      'a promo video plays for each gift so shoppers see exactly what they’re getting',
      'celebration dialogs when a gift is selected, added or changed — a rewarding '
          'moment, not just a checkbox',
      'fully bloc-driven state across selection, cart lock/unlock and notifications',
    ],
    techStack: ['flutter', 'dart', 'bloc', 'animations', 'video_player'],
    // iOS screen recordings of the live feature (added to assets/videos/).
    previewVideo: 'assets/videos/welcome_gift_2.mp4',
    showcase: [
      'assets/videos/welcome_gift_1.mp4',
      'assets/videos/welcome_gift_2.mp4',
      'assets/videos/welcome_gift_3.mp4',
    ],
    accentColor: '#B8324E',
  ),
  Feature(
    id: 'product-recommendation',
    name: 'product recommendation rail',
    context: 'apna mart · ios & android',
    tagline: 'smart "you might also want…" suggestions at add-to-cart',
    shortDescription:
        'a cross-page rail that suggests related products the moment a shopper '
        'adds an item to their cart — live on home, search & category.',
    description:
        'when a shopper adds a product to their cart, this rail slides in with a '
        'curated set of related items — the same "customers also bought" nudge you '
        'see on amazon, built natively for apna mart’s grocery app. it works across '
        'three of the app’s busiest surfaces (home, search and category) from one '
        'shared engine, and is designed to boost basket size without getting in the '
        'shopper’s way: it appears intelligently rather than on every single tap, '
        'and every product shown is tracked so the team can measure what actually '
        'converts. i built the full feature end to end — the state management, the '
        'appearance logic, the analytics, and the multi-phase animations that make '
        'it feel smooth.',
    highlights: [
      'appears right when a product is added to cart, suggesting items shoppers '
          'are likely to buy together — nudging a bigger basket',
      'one shared engine powers the rail across home, search & category instead '
          'of three separate implementations',
      'shows up intelligently — a sampling rule (add-to-cart counter + threshold) '
          'keeps it helpful, not spammy',
      'multi-phase animations: smooth expand/collapse, a one-time entrance so it '
          'never re-animates, and a graceful minimize',
      'every recommendation shown is tracked (impression analytics) so the team '
          'can measure impact on conversions',
      'add / remove products straight from the rail — no need to leave the page',
    ],
    techStack: ['flutter', 'dart', 'bloc', 'animations', 'analytics'],
    // iOS screen recordings of the live feature (added to assets/videos/).
    previewVideo: 'assets/videos/product_rec_3.mp4',
    showcase: [
      'assets/videos/product_rec_1.mp4',
      'assets/videos/product_rec_2.mp4',
      'assets/videos/product_rec_3.mp4',
    ],
    accentColor: '#C25418',
  ),

  Feature(
    id: 'onboarding-revamp',
    name: 'onboarding revamp',
    context: 'apna mart · ios & android',
    tagline: 'a polished first impression, rebuilt from splash to sign-in',
    shortDescription:
        'end-to-end redesign of the app’s onboarding (codename "junction") — '
        'animated splash, a living sign-in screen, language switching & otp login.',
    description:
        'onboarding is the very first thing every new user sees, so i rebuilt it end '
        'to end — internally codenamed "junction". it opens with a smooth splash '
        'animation, then lands on a sign-in screen with a living backdrop: a grid of '
        'product images that drifts diagonally behind the card to make the app feel '
        'alive from the first second. from there a shopper can switch the whole app '
        'between english, hindi and bengali with one tap, then sign in through a clean '
        'phone-number and otp flow. the imagery is driven by remote config, so the '
        'team can refresh the look without shipping an app update — and the animations '
        'are built to stay buttery smooth with isolated repaints.',
    highlights: [
      'rebuilt the full flow — splash → animated sign-in → phone number → otp — as '
          'one cohesive first impression',
      'living sign-in backdrop: a diagonally scrolling grid of product images that '
          'keeps animating behind the card',
      'one-tap language switching (english / hindi / bengali) right on the '
          'onboarding screen',
      'backdrop imagery is remote-config driven — the look can change without an '
          'app release',
      'lottie-powered splash that plays once, then routes intelligently based on '
          'login & location state',
      'tuned for performance with isolated repaint boundaries so the animations '
          'never cost frame drops',
    ],
    techStack: ['flutter', 'dart', 'lottie', 'animations', 'remote config'],
    // iOS screen recordings of the live feature (added to assets/videos/).
    previewVideo: 'assets/videos/onboarding_junction_1.mp4',
    showcase: [
      'assets/videos/onboarding_junction_1.mp4',
      'assets/videos/onboarding_junction_2.mp4',
      'assets/videos/onboarding_junction_3.mp4',
    ],
    accentColor: '#2438E0',
  ),
  Feature(
    id: 'omnia',
    name: 'omnia',
    context: 'acm-juit student chapter · android',
    tagline: 'the app that holds a college coding community together',
    shortDescription:
        'the acm student chapter app — events, sessions, the council and a '
        'profile for every member. the first thing i shipped end to end.',
    description:
        'omnia is the official app of the acm student chapter at juit, and the '
        'first product i took from an idea to something people opened. the '
        'chapter ran on whatsapp forwards and google forms: an event was '
        'announced in a group and lost by the evening, the sessions we had '
        'already run lived in a drive folder nobody could find, and a new '
        'member had no way to see who ran the chapter or what it had done. '
        'omnia gave all of it one place. i started it in january 2024 in figma '
        'rather than in code — sat down with teammates, understood what the '
        'chapter actually needed, and iterated on the flows before building '
        'them. then flutter on top of firebase: auth for members, firestore '
        'for events and council, storage for the photos, and registrations '
        'that append straight into the chapter\'s google sheet. it is also '
        'where i learnt flutter properly — not from a course, but from screens '
        'the people around me were going to use. the repo is still live and '
        'still being pushed to, most recently a move onto supabase.',
    highlights: [
      'login and signup on firebase auth, so a member has an identity in the '
          'chapter rather than a number in a group',
      'a home page of upcoming events, and past ones kept as an archive with '
          'the full write-up and photos instead of a lost forward',
      'the session archive month by month — web dev, fintech, ai & ml, '
          'competitive programming, app development',
      'a community page with the current council and past tenures: every '
          'member, their role and what they ran',
      'a profile each member owns — avatar, bio and their linkedin, github '
          'and twitter, editable in the app',
      'event registration that writes a row into the chapter\'s google sheet '
          'and uploads the payment screenshot to firebase storage',
    ],
    techStack: [
      'flutter',
      'dart',
      'firebase auth',
      'firestore',
      'firebase storage',
      'google sheets',
      'supabase',
      'figma',
    ],
    // A walkthrough of the shipped android build, cut into four passes.
    thumbnailImage: 'assets/images/omnia/poster.jpg',
    previewVideo: 'assets/videos/omnia_1.mp4',
    showcase: [
      'assets/videos/omnia_1.mp4',
      'assets/videos/omnia_2.mp4',
      'assets/videos/omnia_3.mp4',
      'assets/videos/omnia_4.mp4',
    ],
    link: 'https://github.com/kartikaeyy/Omnia',
    linkLabel: 'see the repo',
    // The app icon's own purple; the night edition lifts it into a violet.
    accentColor: '#3B1E63',
  ),
];

/// Image-and-text cards — hackathons, side projects, weekend builds.
///
/// To add one: drop the photo in `assets/images/` and copy the entry below.
/// Anything listed here lands in the carousel after the features — to slot a
/// post between them instead, spell [kWorkItems] out entry by entry.
const kPosts = [
  Post(
    id: 'nutrikit',
    title: 'nutrikit for blinkit',
    context: 'swiftdidload hackathon · eternal · july 2026',
    body:
        'a hackathon build with tejash seth and saurabh dhingra: scan a grocery '
        'barcode, read the label in teaspoons instead of milligrams, and swap '
        'to a better-rated product without ever leaving blinkit.',
    description:
        'swiftdidload gave us complete freedom to find a real user problem and '
        'build for consumers across eternal — blinkit, zomato, district and '
        'hyperpure. i had been sitting on this idea for a while and realised the '
        'hackathon was its best possible home. nutrition labels are hard to read '
        'mid-shop: raw per-100g values mean little, there is no instant score to '
        'compare two similar products, and people leave the app to research a '
        'packet — friction that breaks the shopping trip. nutrikit puts that '
        'answer inside the cart. the inspiration was zomato\'s health mode; the '
        'same transparency simply did not exist in grocery. we did not win, but '
        'the eternal team backed the problem statement, the product thinking and '
        'the polish of the mvp flow — and i would build it again.',
    highlights: [
      'scan a product barcode for instant nutrition insight, right inside the '
          'shopping flow',
      'nutrition translated into things people actually picture — teaspoons of '
          'sugar rather than grams per 100g',
      'a nutri-score and a simple metric breakdown so two similar products can '
          'be compared at a glance',
      'healthier alternatives pulled from what blinkit already stocks',
      'one-tap healthier swaps offered during add-to-cart, where the decision '
          'is actually being made',
      'a personalised health journey that tracks how orders improve over time',
    ],
    // Cover first, then the deck and the photos from the day.
    image: 'assets/images/nutrikit/slide_01.jpg',
    gallery: [
      'assets/images/nutrikit/slide_02.jpg',
      'assets/images/nutrikit/slide_03.jpg',
      'assets/images/nutrikit/slide_04.jpg',
      'assets/images/nutrikit/slide_05.jpg',
      'assets/images/nutrikit/slide_06.jpg',
      'assets/images/nutrikit/slide_07.jpg',
      'assets/images/nutrikit/slide_08.jpg',
      'assets/images/nutrikit/slide_09.jpg',
      'assets/images/nutrikit/slide_10.jpg',
      'assets/images/nutrikit/slide_11.jpg',
      'assets/images/nutrikit/team.jpg',
    ],
    tags: ['barcode scan', 'nutri-score', 'team of 3', '2-day build'],
    sideImage: 'assets/images/nutrikit/building.jpg',
    sideCaption: 'putting the deck together, the night before the demo.',
    link:
        'https://www.linkedin.com/feed/update/urn:li:activity:7484671260258426881/',
    linkLabel: 'read the post',
    accentColor: '#0C831F',
  ),
];

/// The carousel, in order. Mix features and posts freely — the work page picks
/// the right card for whatever is in the list.
const kWorkItems = <WorkItem>[...kFeatures, ...kPosts];

const kExperiences = [
  Experience(
    company: 'apna mart',
    role: 'mobile developer',
    period: 'jan 2026 – present',
    // Consumer app icon, apnamart.in.
    logoAsset: 'assets/images/logos/apna_mart.jpg',
    description:
        'building the ios and android consumer app — shipping features, animations, and '
        'localization while resolving production issues.',
    highlights: [
      'revamped the onboarding flow end to end, from splash to home page',
      'built a config-gated floating offer nudge banner on cart items to surface '
          'offer visibility',
      'made force/soft app-update dialogs server driven (heading, description, '
          'remote icon with fallback)',
      'standardized currency formatting & rounding logic across cart, offer tags '
          '& mrp displays',
      'added google phone number hint to android (native) onboarding, removing '
          'manual entry at signup',
      'optimized the google places integration, cutting per-request api billing '
          '& response payload size',
      'built the welcome gift feature with a dynamic widget and cart-level logic, '
          'targeting first-order conversion',
      'developed a cross-page product recommendation rail across home, search & '
          'category pages',
      'led app-wide localization for hindi & bengali, with in-app language '
          'switching from the profile page',
      'rebuilt the gps & location-permission flow for ios/android, handling '
          'location, denials & fallback states',
      'implemented edge-to-edge system ui styling with safe-area handling for '
          'bottom sheets and keyboard layouts',
      'resolved production issues spanning payment flow, cart logic, monthly '
          'crashlytics, app size & ui overflow',
      'built multi-phase ui animations with animationcontrollers for '
          'recommendation rail entrances, auto-scrolling carousels & scale '
          'transitions for offer prices',
    ],
  ),
  Experience(
    company: 'ente',
    role: 'software engineer intern',
    period: 'aug 2025 – oct 2025',
    // Site icon, ente.io.
    logoAsset: 'assets/images/logos/ente.png',
    description:
        'contributed to the open-source, end-to-end encrypted photos app at ente.io.',
    highlights: [
      'redesigned bottom sheets & components for gallery, albums and people tabs',
      'implemented adaptive ui like collapsing & expanding on scroll',
      'updated icon grouping and swiping logic',
    ],
  ),
  Experience(
    company: 'imagined',
    role: 'flutter intern',
    period: 'oct 2024 – nov 2024',
    // Site icon, imagined.studio.
    logoAsset: 'assets/images/logos/imagined.png',
    description:
        'contributed to solo, a platform connecting 100+ brands and influencers.',
    highlights: [
      'created the referral screen and home carousel with frontend card updates',
      'redesigned the kyc & payouts sections, improving usability for 1,000+ users',
    ],
  ),
];

const kEducation = Education(
  institution: 'jaypee university of information technology',
  degree: 'b.tech in computer science engineering',
  period: 'may 2026',
  detail: 'cgpa: 7.6',
);

const kSkills = [
  'flutter',
  'dart',
  'swift',
  'firebase',
  'provider',
  'bloc',
  'riverpod',
  'mvvm',
  'feature first',
  'git/github',
  'clickhouse',
  'figma',
  'claude code',
  'xcode',
  'android studio',
  'linux',
  'kotlin',
  'android jetpack',
];

const kEmail = 'kartikeyswork@gmail.com';
const kPhone = '+91-6307195977';

/// The photograph on the hero. Swap the file to change the picture.
const kPortrait = 'assets/images/kartikey.jpg';

/// The résumé, bundled with the site. Swap the file to update it.
const kResume = 'assets/resume/kartikey_srivastava_resume.pdf';

/// Where a browser can fetch that same file: a web build serves every bundled
/// asset under its own `assets/` root, which is why the prefix appears twice.
const kResumeUrl = 'assets/$kResume';
const kGithub = 'https://github.com/kartikaeyy';
const kLinkedin = 'https://linkedin.com/in/kartikaeyy';
