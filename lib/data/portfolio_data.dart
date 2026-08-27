/// A single shipped feature shown in the "My Work" showcase. Each entry is one
/// piece of product work (e.g. a recommendation rail), not a whole app.
class Feature {
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
    required this.accentColor,
  });
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
    name: 'Welcome Gift',
    context: 'Apna Mart · iOS & Android',
    tagline: 'A free gift that turns first-time visitors into first orders',
    shortDescription:
        'New shoppers pick a free welcome gift that unlocks in their cart once '
        'the order crosses a minimum — nudging them to place a first purchase.',
    description:
        'The Welcome Gift is a growth feature that greets a brand-new shopper with '
        'a free gift they get to choose themselves. They pick it during onboarding, '
        'then it rides along in their cart as a locked reward that unlocks the moment '
        'their order crosses a small minimum value — a gentle nudge to complete that '
        'important first purchase. If the gift they want is out of stock, they can opt '
        'in to be notified when it’s back, so the offer never feels like a dead end. I '
        'built the full experience — the gift selection screen, the locked/unlocked '
        'cart states, promo-video playback for each gift, and the celebration moments '
        'when a gift is picked and added.',
    highlights: [
      'A free gift for new shoppers, chosen during onboarding — a strong reason to '
          'place that first order',
      'Locks in the cart and unlocks once the order crosses a minimum value, '
          'nudging a bigger, completed basket',
      'Out-of-stock gifts offer a "notify me" opt-in, so the offer never dead-ends',
      'A promo video plays for each gift so shoppers see exactly what they’re getting',
      'Celebration dialogs when a gift is selected, added or changed — a rewarding '
          'moment, not just a checkbox',
      'Fully BLoC-driven state across selection, cart lock/unlock and notifications',
    ],
    techStack: ['Flutter', 'Dart', 'BLoC', 'Animations', 'video_player'],
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
    name: 'Product Recommendation Rail',
    context: 'Apna Mart · iOS & Android',
    tagline: 'Smart "you might also want…" suggestions at add-to-cart',
    shortDescription:
        'A cross-page rail that suggests related products the moment a shopper '
        'adds an item to their cart — live on Home, Search & Category.',
    description:
        'When a shopper adds a product to their cart, this rail slides in with a '
        'curated set of related items — the same "customers also bought" nudge you '
        'see on Amazon, built natively for Apna Mart’s grocery app. It works across '
        'three of the app’s busiest surfaces (Home, Search and Category) from one '
        'shared engine, and is designed to boost basket size without getting in the '
        'shopper’s way: it appears intelligently rather than on every single tap, '
        'and every product shown is tracked so the team can measure what actually '
        'converts. I built the full feature end to end — the state management, the '
        'appearance logic, the analytics, and the multi-phase animations that make '
        'it feel smooth.',
    highlights: [
      'Appears right when a product is added to cart, suggesting items shoppers '
          'are likely to buy together — nudging a bigger basket',
      'One shared engine powers the rail across Home, Search & Category instead '
          'of three separate implementations',
      'Shows up intelligently — a sampling rule (add-to-cart counter + threshold) '
          'keeps it helpful, not spammy',
      'Multi-phase animations: smooth expand/collapse, a one-time entrance so it '
          'never re-animates, and a graceful minimize',
      'Every recommendation shown is tracked (impression analytics) so the team '
          'can measure impact on conversions',
      'Add / remove products straight from the rail — no need to leave the page',
    ],
    techStack: ['Flutter', 'Dart', 'BLoC', 'Animations', 'Analytics'],
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
    name: 'Onboarding Revamp',
    context: 'Apna Mart · iOS & Android',
    tagline: 'A polished first impression, rebuilt from splash to sign-in',
    shortDescription:
        'End-to-end redesign of the app’s onboarding (codename "Junction") — '
        'animated splash, a living sign-in screen, language switching & OTP login.',
    description:
        'Onboarding is the very first thing every new user sees, so I rebuilt it end '
        'to end — internally codenamed "Junction". It opens with a smooth splash '
        'animation, then lands on a sign-in screen with a living backdrop: a grid of '
        'product images that drifts diagonally behind the card to make the app feel '
        'alive from the first second. From there a shopper can switch the whole app '
        'between English, Hindi and Bengali with one tap, then sign in through a clean '
        'phone-number and OTP flow. The imagery is driven by remote config, so the '
        'team can refresh the look without shipping an app update — and the animations '
        'are built to stay buttery smooth with isolated repaints.',
    highlights: [
      'Rebuilt the full flow — splash → animated sign-in → phone number → OTP — as '
          'one cohesive first impression',
      'Living sign-in backdrop: a diagonally scrolling grid of product images that '
          'keeps animating behind the card',
      'One-tap language switching (English / Hindi / Bengali) right on the '
          'onboarding screen',
      'Backdrop imagery is remote-config driven — the look can change without an '
          'app release',
      'Lottie-powered splash that plays once, then routes intelligently based on '
          'login & location state',
      'Tuned for performance with isolated repaint boundaries so the animations '
          'never cost frame drops',
    ],
    techStack: ['Flutter', 'Dart', 'Lottie', 'Animations', 'Remote Config'],
    // iOS screen recordings of the live feature (added to assets/videos/).
    previewVideo: 'assets/videos/onboarding_junction_1.mp4',
    showcase: [
      'assets/videos/onboarding_junction_1.mp4',
      'assets/videos/onboarding_junction_2.mp4',
      'assets/videos/onboarding_junction_3.mp4',
    ],
    accentColor: '#2438E0',
  ),
];

const kExperiences = [
  Experience(
    company: 'Apna Mart',
    role: 'Mobile Developer',
    period: 'Jan 2026 – Present',
    // Consumer app icon, apnamart.in.
    logoAsset: 'assets/images/logos/apna_mart.jpg',
    description:
        'Building the iOS and Android Consumer App — shipping features, animations, and '
        'localization while resolving production issues.',
    highlights: [
      'Revamped the onboarding flow end to end, from Splash to Home page',
      'Built a config-gated floating offer nudge banner on cart items to surface '
          'offer visibility',
      'Made force/soft app-update dialogs server driven (heading, description, '
          'remote icon with fallback)',
      'Standardized currency formatting & rounding logic across cart, offer tags '
          '& MRP displays',
      'Added Google Phone Number Hint to Android (native) onboarding, removing '
          'manual entry at signup',
      'Optimized the Google Places integration, cutting per-request API billing '
          '& response payload size',
      'Built the Welcome Gift feature with a dynamic widget and cart-level logic, '
          'targeting first-order conversion',
      'Developed a cross-page Product Recommendation Rail across Home, Search & '
          'Category pages',
      'Led app-wide localization for Hindi & Bengali, with in-app language '
          'switching from the profile page',
      'Rebuilt the GPS & location-permission flow for iOS/Android, handling '
          'location, denials & fallback states',
      'Implemented edge-to-edge system UI styling with safe-area handling for '
          'bottom sheets and keyboard layouts',
      'Resolved production issues spanning payment flow, cart logic, monthly '
          'Crashlytics, app size & UI overflow',
      'Built multi-phase UI animations with AnimationControllers for '
          'recommendation rail entrances, auto-scrolling carousels & scale '
          'transitions for offer prices',
    ],
  ),
  Experience(
    company: 'Ente',
    role: 'Software Engineer Intern',
    period: 'Aug 2025 – Oct 2025',
    // Site icon, ente.io.
    logoAsset: 'assets/images/logos/ente.png',
    description:
        'Contributed to the open-source, end-to-end encrypted Photos app at ente.io.',
    highlights: [
      'Redesigned bottom sheets & components for gallery, albums and people tabs',
      'Implemented adaptive UI like collapsing & expanding on scroll',
      'Updated icon grouping and swiping logic',
    ],
  ),
  Experience(
    company: 'Imagined',
    role: 'Flutter Intern',
    period: 'Oct 2024 – Nov 2024',
    // Site icon, imagined.studio.
    logoAsset: 'assets/images/logos/imagined.png',
    description:
        'Contributed to Solo, a platform connecting 100+ brands and influencers.',
    highlights: [
      'Created the Referral screen and Home Carousel with frontend card updates',
      'Redesigned the KYC & Payouts sections, improving usability for 1,000+ users',
    ],
  ),
];

const kEducation = Education(
  institution: 'Jaypee University of Information Technology',
  degree: 'B.Tech in Computer Science Engineering',
  period: 'May 2026',
  detail: 'CGPA: 7.6',
);

const kSkills = [
  'Flutter',
  'Dart',
  'Swift',
  'Firebase',
  'Provider',
  'Bloc',
  'Riverpod',
  'MVVM',
  'Feature First',
  'Git/GitHub',
  'Clickhouse',
  'Figma',
  'Claude Code',
  'Xcode',
  'Android Studio',
  'Linux',
  'Kotlin',
  'Android Jetpack',
];

const kEmail = 'kartikeyswork@gmail.com';
const kPhone = '+91-6307195977';
const kGithub = 'https://github.com/kartikaeyy';
const kLinkedin = 'https://linkedin.com/in/kartikaeyy';
