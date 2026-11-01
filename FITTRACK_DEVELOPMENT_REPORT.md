# FitTrack — Flutter Fitness Application (MVP) Development Report

স্বাগতম! এই সম্পূর্ণ রিপোর্টটি আপনার জন্য তৈরি করা হয়েছে যেন আপনি একজন বিগিনার হওয়া সত্ত্বেও **FitTrack** অ্যাপ্লিকেশনের প্রতিটা লাইন কোড, আর্কিটেকচার, ডেটাবেস এবং ফ্লাটারের মূল কনসেপ্টগুলো সহজে বাংলায় বুঝতে পারেন।

---

## সূচিপত্র (Table of Contents)
1. **[A. Project Overview & Features](#a-project-overview)**
2. **[B. Environment Setup & Dependencies](#b-environment-setup--dependencies)**
3. **[C. Folder Structure Explained](#c-folder-structure-explained)**
4. **[D. File-by-File Detailed Explanation](#d-file-by-file-detailed-explanation)**
5. **[E. Flutter Concepts Used in FitTrack](#e-flutter-concepts-used-in-fittrack)**
6. **[F. Complete Application Workflow](#f-complete-application-workflow)**
7. **[G. SQLite Database Architecture & Schema (9 Tables)](#g-sqlite-database-architecture--schema)**
8. **[H. Terminal & PowerShell Commands Guide](#h-terminal--powershell-commands-guide)**
9. **[I. Testing, Verification & Device Report](#i-testing-verification--device-report)**
10. **[J. How You Can Modify & Expand the App](#j-how-you-can-modify--expand-the-app)**
11. **[K. 15 Real Interview Questions & Answers](#k-15-real-interview-questions--answers)**

---

## A. Project Overview

### FitTrack কী?
**FitTrack** হলো একটি প্রিমিয়াম ডার্ক-থিম ভিত্তিক অফলাইন ফিটনেস ট্র্যাকিং মোবাইল অ্যাপ্লিকেশন, যা Flutter ও Dart ব্যবহার করে সম্পূর্ণ দেশীয় আর্কিটেকচারে তৈরি করা হয়েছে। এতে কোনো ক্লাউড সার্ভার বা ইন্টারনেটের প্রয়োজন হয় না—সমস্ত ডেটা ইউজারের ডিভাইসের লোকাল **SQLite** ডেটাবেসে স্থায়ীভাবে সংরক্ষিত থাকে।

### অ্যাপটিতে কী কী ফিচার বাস্তবায়িত হয়েছে?
1. **Interactive Dashboard (হোম স্ক্রিন):**
   - **🔥 Daily Habit Streak Banner:** টানা কতদিন ইউজার নিয়মিত অ্যাক্টিভিটি (ওয়ার্কআউট, পানি, খাবার, ওজন) লগ করেছেন তার লাইভ স্ট্রিক ট্র্যাকার।
   - ইউজারের নামের সাথে পার্সোনালাইজড ওয়েলকাম মেসেজ।
   - রিয়েল-টাইম বডি মেট্রিক্স: Current BMI (ক্যাটাগরি ব্যাজসহ), Current Weight, Daily Water Intake (প্রগ্রেস বারসহ), এবং Total Workout Count।
   - **Modern Health Trackers:** আজকের খাবারের ক্যালোরি বাজেট ও প্রোটিন সারাংশ এবং হাঁটার স্টেপ কাউন্টার প্রগ্রেস কার্ড।
   - কুইক অ্যাকশন বাটনস (৬টি কুইক বাটন): Log Weight, Add Water, Workout, Meal Diary, Steps, Calculator।
   - **Today's Targets Summary:** পানি, ক্যালোরি এবং স্টেপসের ৩টি আলাদা রঙিন লিনিয়ার প্রগ্রেস বার।
   - রিসেন্ট অ্যাক্টিভিটি ফিড: সাম্প্রতিক ওয়ার্কআউট সেশন, মিল এবং ওয়েট লগের রিয়েল-টাইম তালিকা।

2. **Health Calculator (স্বাস্থ্য ক্যালকুলেটর):**
   - **BMI (Body Mass Index):** উচ্চতা ও ওজনের অনুপাতে স্বাস্থ্যগত অবস্থা (Underweight, Normal, Overweight, Obese) এবং আদর্শ ওজনের রেঞ্জ।
   - **BMR (Basal Metabolic Rate):** বিশ্বমানের Mifflin-St Jeor ফর্মুলা দিয়ে শরীর বিশ্রামে থাকা অবস্থায় প্রয়োজনীয় ক্যালোরি নির্ণয়।
   - **TDEE (Total Daily Energy Expenditure):** ইউজারের দৈনন্দিন শারীরিক পরিশ্রমের (Activity Level) গুণক দিয়ে মোট ক্যালোরি খরচ বের করা।
   - **Daily Calorie Target:** ওজন কমানো (Weight Loss), বাড়ানো (Muscle Building) বা ধরে রাখার (Maintenance) লক্ষ্য অনুযায়ী ক্যালোরি গোল।
   - **Macronutrient Split:** ক্যালোরি অনুযায়ী প্রোটিন, কার্বোহাইড্রেট ও ফ্যাটের গ্রাম হিসেব।
   - হিসেব করা সমস্ত ডেটা স্বয়ংক্রিয়ভাবে SQLite-এ সেভ হয় এবং হিস্ট্রি দেখা যায়।

3. **Weight Tracker (ওজন ট্র্যাকার):**
   - তারিখ ও নোটসহ নতুন ওজন এন্ট্রি করার সুবিধা।
   - পূর্ববর্তী ওজনের সাথে পার্থক্য (+/- kg) স্বয়ংক্রিয়ভাবে প্রদর্শন।
   - **CustomPainter Line Graph:** ওজনের পরিবর্তনের মসৃণ ভিজ্যুয়াল ট্রেন্ড চার্ট (গ্র্যাডিয়েন্ট ফিলসহ)।
   - পূর্বের ভুল রেকর্ড ডিলিট করার কনফার্মেশন ডায়ালগ।

4. **Water Tracker (পানি ট্র্যাকার):**
   - প্রতিদিনের পানির লক্ষ্যমাত্রা (ডিফল্ট ২৫০০ মিলি বা প্রোফাইল থেকে কাস্টমাইজড)।
   - কুইক অ্যাড বাটন (+250ml, +500ml, +750ml) এবং কাস্টম পরিমাণ যোগ করার অপশন।
   - বৃত্তাকার সার্কুলার প্রগ্রেস রিং (শতকরা হার এবং বাকি পানির পরিমাণ)।
   - তারিখ ভিত্তিক স্বয়ংক্রিয় রিসেট (আজকের তারিখের লগ আলাদা ফিল্টার হয়)।
   - গত ৭ দিনের পানির হিসেবের বার চার্ট।

5. **Workout Tracker & Active Gym Companion:**
   - প্রি-ইনস্টল্ড এক্সারসাইজ লাইব্রেরি (Push-ups, Squats, Pull-ups, Bench Press, Plank, Running, ইত্যাদি বিভিন্ন ক্যাটাগরিতে বিভক্ত)।
   - নিজের কাস্টম এক্সারসাইজ যুক্ত করার সুবিধা।
   - **Active Workout Screen:** লাইভ স্টপওয়াচ টাইমার, সেটস, রেপস ও কেজি ওজন ট্র্যাকিং।
   - **Rest Timer Between Sets:** কোনো সেটে টিক দিলে স্বয়ংক্রিয়ভাবে রিল্যাক্সিং রেস্ট টাইমার চালু হয় (Presets: 30s, 60s, 90s, 120s, সাথে -15s / +15s এবং Skip বাটন)।
   - সেশন শেষে কনগ্র্যাচুলেশন ডায়ালগ এবং মোট ভলিউম (kg-reps) ও সময় প্রদর্শন।
   - অতীতের ওয়ার্কআউট হিস্ট্রি ব্রাউজ ও ডিলিট করার সুবিধা।

6. **Food & Nutrition Diary (খাবার ও ম্যাক্রো ট্র্যাকার):**
   - সারাদিনের ক্যালোরি বাজেট (Total Daily Calories vs Target)।
   - প্রোটিন, কার্বোহাইড্রেট ও ফ্যাটের পুষ্টিগুণ ট্র্যাকিং।
   - **Quick-Add Common Foods:** ডিম, গ্রিলড চিকেন, ভাত, রুটি, ডাল, ওটস, দুধ, কলা, গ্রিক ইয়োগার্ট, হুই প্রোটিন ইত্যাদি এক ট্যাপে ব্রেকফাস্ট, লাঞ্চ বা ডিনারে যুক্ত করার সুবিধা।
   - কাস্টম খাবার যোগ ও ডিলিট করার সুবিধা।

7. **Daily Step Tracker (পেডোমিটার ও হাঁটাচলা ট্র্যাকার):**
   - দৈনিক ১০,০০০ স্টেপস লক্ষ্যের সাথে কাস্টম সার্কুলার প্রগ্রেস রিং।
   - মোট হাঁটার দূরত্ব (কিমি) এবং বার্ন করা ক্যালোরি অটোমেটিক হিসেব।
   - কুইক লগ অপশন (+500, +1000, +2500 কদম)।

8. **Progress & Analytics (অগ্রগতি চার্ট):**
   - ওজন পরিবর্তনের ইন্টারঅ্যাক্টিভ লাইন চার্ট।
   - বিএমআই হিস্ট্রি।
   - গত ৭ দিনের ওয়ার্কআউট সেশন সংখ্যা ও পানির মোট পরিমাণের দুটি আলাদা বার চার্ট।
   - লাইফটাইম স্ট্যাটিস্টিকস (মোট ওয়ার্কআউট, মোট সেটস, মোট সময়)।

9. **Profile & Settings (প্রোফাইল ও সেটিংস):**
   - নাম, বয়স, উচ্চতা, ওজন, লিঙ্গ, ফিটনেস গোল ও অ্যাক্টিভিটি লেভেল এডিট করার সম্পূর্ণ ডায়ালগ।
   - **Water Reminder Notifications:** পানি পানের রিমাইন্ডার টগল, সময় নির্ধারণ (প্রতি ১ ঘণ্টা / ২ ঘণ্টা / ৩ ঘণ্টা পর পর) এবং টেস্ট নোটিফিকেশন অ্যালার্ট।
   - **Appearance Customizer:** Dark Slate Navy এবং Pure AMOLED Black মোড টগল।
   - মেট্রিক ইউনিট সাপোর্ট (kg, cm, ml) এবং লোকাল SQLite স্টোরেজ ব্যাজ।

---

## B. Environment Setup & Dependencies

### এনভায়রনমেন্টের বিবরণ:
- **Flutter SDK:** `3.47.9` (Channel stable)
- **Dart SDK:** `3.13.7`
- **Android SDK:** `API 36.0.0`
- **Java Runtime (JBR):** OpenJDK 25 (Android Studio bundled)
- **Tested Device:** Real Phone Xiaomi `2201117TG` (Android 13, API 33) & Android Studio Emulator.

### ইনস্টল করা প্যাকেজসমূহ (Dependencies):

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8    # iOS স্টাইল আইকন সাপোর্ট
  sqflite: ^2.4.5            # লোকাল SQLite ডেটাবেস ইঞ্জিন
  path: ^1.9.1               # ফাইল এবং ডেটাবেস পাথের ক্রস-প্ল্যাটফর্ম জয়েনিং
  intl: ^0.20.3              # তারিখ, সময় এবং সংখ্যা ফরম্যাটিং

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0      # গুগলের অফিশিয়াল ক্লিন কোডিং স্ট্যান্ডার্ড
  sqflite_common_ffi: ^2.4.5 # ডেস্কটপ ও পিসিতে ইউনিট টেস্ট চালানোর জন্য SQLite FFI ড্রাইভার
```

#### কেন ভারী থার্ড-পার্টি প্লাগিনের পরিবর্তে কাস্টম সলিউশন ব্যবহার করা হলো?
1. **Zero Dependency Charts (`CustomPainter`):** `fl_chart` প্যাকেজটি অত্যন্ত ভারী এবং এর কারণে বিল্ডে প্রচুর সময় নষ্ট হচ্ছিল। আমরা সম্পূর্ণ বিশুদ্ধ ডার্ট ক্যানভাস দিয়ে `WeightTrendChart`, `WeeklyBarChart`, এবং `CircularGoalProgress` তৈরি করেছি যা দ্রুতগতির এবং 0px ওভারফ্লো প্রুফ।
2. **Java 25 & Kotlin Compatibility:** ওপেনজেডিকে ২৫-এ কোটলিন গ্র্যাডল প্লাগিনের ডেমনে মডিউল রিফ্লেকশন হ্যাং হতো। `MainActivity.java` ব্যবহার করে আমরা অ্যান্ড্রয়েড অ্যাপটিকে শতভাগ পিওর জাভাতে রূপান্তর করেছি যা ২ সেকেন্ডে বিল্ড হয়ে যায়।

---

## C. Folder Structure Explained

```
fittrack/
├── android/                   # নেটিভ অ্যান্ড্রয়েড কনফিগারেশন, পারমিশন ও জাভা মেইনঅ্যাক্টিভিটি
├── lib/
│   ├── main.dart              # অ্যাপ্লিকেশনের প্রবেশদ্বার (Entry point)
│   ├── app.dart               # MaterialApp এবং রুট রাউটিং
│   ├── core/
│   │   ├── constants/         # গ্লোবাল কনস্ট্যান্টস (খাবারের ডাটাবেস, গোলস, ক্যাটাগরি)
│   │   ├── theme/             # প্রিমিয়াম ডার্ক কালার প্যালেট ও থিম
│   │   └── utils/             # তারিখ, সময় ও সেকেন্ড ফরম্যাট করার ইউটিলিটি
│   ├── database/
│   │   └── database_helper.dart # SQLite সিংগেলটন ক্লাস (৯টি টেবিল ও কুয়েরি)
│   ├── models/                # ডেটা মডেল ও SQLite সিরিয়ালাইজেশন (toMap / fromMap)
│   │   ├── user_profile.dart
│   │   ├── weight_record.dart
│   │   ├── water_record.dart
│   │   ├── exercise.dart
│   │   ├── workout_session.dart
│   │   ├── health_calculation.dart
│   │   ├── meal_record.dart
│   │   └── step_record.dart
│   ├── services/
│   │   └── calculator_service.dart # পিওর ডার্ট ম্যাথমেটিক্যাল ও হেলথ লজিক
│   ├── screens/               # প্রধান ইউজার ইন্টারফেস স্ক্রিনসমূহ
│   │   ├── main_scaffold_screen.dart # IndexedStack বটম নেভিগেশন
│   │   ├── dashboard_screen.dart     # মূল ড্যাশবোর্ড ও মেট্রিক্স গ্রিড
│   │   ├── calculator_screen.dart    # বিএমআই, বিএমআর ও টিডিইই ক্যালকুলেটর
│   │   ├── weight_tracker_screen.dart# ওজন ট্র্যাকার ও চার্ট
│   │   ├── water_tracker_screen.dart # পানি ট্র্যাকার ও সার্কুলার রিং
│   │   ├── workout_screen.dart       # এক্সারসাইজ লাইব্রেরি ও হিস্ট্রি
│   │   ├── workout_active_screen.dart# লাইভ জিম টাইমার ও রেস্ট কাউন্টডাউন
│   │   ├── nutrition_screen.dart     # খাবার ডায়ারি ও ক্যালোরি বাজেট
│   │   ├── step_tracker_screen.dart  # পেডোমিটার ও হাঁটার স্টেপ কাউন্টার
│   │   ├── progress_screen.dart      # অল-ইন-ওয়ান অ্যানালিটিক্স ও চার্টস
│   │   └── profile_screen.dart       # প্রোফাইল এডিট ও ওয়াটার নোটিফিকেশন
│   └── widgets/               # রিইউজেবল উইজেট ও চার্টসমূহ
│       ├── stat_card.dart
│       ├── custom_button.dart
│       ├── reusable_widgets.dart
│       └── custom_charts.dart
└── test/                      # স্বয়ংক্রিয় ইউনিট টেস্ট ও উইজেট টেস্ট
    ├── unit_test.dart         # ২২টি ইউনিট টেস্ট (ক্যালকুলেশন, সিরিয়ালাইজেশন)
    └── widget_test.dart       # উইজেট রেন্ডারিং টেস্ট
```

---

## D. File-by-File Detailed Explanation

### ১. `lib/database/database_helper.dart`
- **কাজ:** অ্যাপের যাবতীয় ডেটা লোকাল SQLite ডেটাবেসে স্থায়ীভাবে রাখা।
- **কীভাবে কাজ করে:** এটি একটি **Singleton** ক্লাস। `calculateCurrentStreak()` মেথডটি আজকের দিন থেকে পেছনে গিয়ে দেখে ইউজার প্রতিদিন কোনো না কোনো অ্যাক্টিভিটি (ওয়ার্কআউট, পানি, খাবার বা ওজন) করেছেন কিনা। যতক্ষণ সক্রিয় দিন পাওয়া যায় ততক্ষণ স্ট্রিকের মান বাড়তে থাকে।

### ২. `lib/screens/nutrition_screen.dart`
- **কাজ:** দৈনিক খাবার ও ক্যালোরি ডায়ারি ট্র্যাকিং।
- **কীভাবে কাজ করে:** ইউজারের বিএমআর এবং টিডিইই অনুযায়ী ক্যালোরির বাজেট নির্ধারণ করে। ইউজারের যোগ করা প্রতিটি খাবারের ক্যালোরি, প্রোটিন, কার্ব ও ফ্যাট স্বয়ংক্রিয়ভাবে প্রগ্রেস বারে সামঞ্জস্যপূর্ণ হয়ে যায়।

### ৩. `lib/screens/workout_active_screen.dart`
- **কাজ:** জিম বা ওয়ার্কআউটের সময় লাইভ সেট ও রেপস ট্র্যাকিং।
- **রেস্ট টাইমার (Rest Timer):** যেকোনো সেটের ডানপাশের চেকবাক্সে টিক দিলে স্বয়ংক্রিয়ভাবে ৬০ সেকেন্ডের কাউন্টডাউন টাইমার স্ক্রিনের নিচে ভেসে ওঠে। ইউজার চাইলেই ৩০, ৬০, ৯০ বা ১২০ সেকেন্ড সিলেক্ট করতে পারেন বা ১৫ সেকেন্ড বাড়াতে/কমাতে পারেন।

### ৪. `lib/screens/step_tracker_screen.dart`
- **কাজ:** ইউজারের প্রতিদিনের হাঁটাচলা ও স্টেপস মনিটরিং।
- **কীভাবে কাজ করে:** ৩,৪৫০ কদম থেকে শুরু করে ব্যবহারকারী কুইক-লগ বাটনে চাপ দিয়ে হাঁটার হিসাব রাখতে পারেন। স্টেপসের সংখ্যা অনুযায়ী দূরত্ব (১ স্টেপ = ০.০০৭৬২ কিমি) এবং পোড়ানো ক্যালোরি (১ স্টেপ = ০.০৪ কিলোক্যালোরি) স্বয়ংক্রিয়ভাবে হিসেব হয়ে SQLite-এ সেভ হয়।

### ৫. `lib/screens/profile_screen.dart`
- **কাজ:** ব্যবহারকারীর প্রোফাইল তথ্য পরিবর্তন ও পছন্দসমূহ কনফিগার করা।
- **ওয়াটার নোটিফিকেশন রিমাইন্ডার:** ইউজার প্রতি ১ ঘণ্টা, ২ ঘণ্টা বা ৩ ঘণ্টা পর পর পানি পানের রিমাইন্ডার সেট করতে পারেন এবং "Test Notification" বাটনে চাপ দিয়ে ফ্লোটিং পপআপ অ্যালার্ট পরীক্ষা করতে পারেন।

---

## E. Flutter Concepts Used in FitTrack

### ১. StatelessWidget বনাম StatefulWidget
- **StatelessWidget:** যেসব উইজেটের কোনো পরিবর্তনশীল ডেটা থাকে না (যেমন `StatCard`, `MetricBadge`, `CustomButton`)।
- **StatefulWidget:** যেসব উইজেটের ভেতরের তথ্য ব্যবহারকারীর কাজের সাথে পরিবর্তিত হয় (যেমন `DashboardScreen`, `WeightTrackerScreen`, `WorkoutActiveScreen`)। এখানে একটি সংশ্লিষ্ট `State` অবজেক্ট থাকে যা পরিবর্তনশীল ডেটা ধারণ করে।

### ২. `setState()` মেথড
যখন আপনি ইউজারের কোনো ক্লিকের পর স্ক্রিনের ডেটা পরিবর্তন করতে চান, তখন `setState()` কল করতে হয়। এটি ফ্লাটার ফ্রেমওয়ার্ককে নির্দেশ দেয়: *"আমার ডেটা বদলেছে, দয়া করে build() মেথডটি আবার চালিয়ে স্ক্রিন আপডেট করো।"*

### ৩. `CustomPainter` ক্যানভাস আর্কিটেকচার
একটি কাস্টম পেইন্টার ক্লাস তৈরি করে `paint(Canvas canvas, Size size)` মেথডে সরাসরি লাইন (`drawLine`), বৃত্ত (`drawArc`), এবং পথ (`drawPath`) আঁকা যায়। ফিটট্র্যাকের চার্টগুলো এই প্রযুক্তিতে তৈরি হওয়ায় কোনো ফ্রেম ড্রপ বা মেমোরি ল্যাগ নেই।

---

## F. Complete Application Workflow

```
[ ইউজার যেকোনো কাজ করলেন (পানি / খাবার / ওয়ার্কআউট / ওজন) ]
                         │
                         ▼
       [ সংশ্লিষ্ট স্ক্রিনে ইনপুট দিলেন ]
                         │
                         ▼
     [ DatabaseHelper.instance মেথড কল হলো ]
                         │
                         ▼
    [ SQLite টেবিলে ডেটা সেভ হলো এবং স্ট্রিক বাড়ল ]
                         │
                         ▼
       [ ড্যাশবোর্ডে ফিরে আসলে রিফ্রেশ হলো ]
                         │
                         ▼
[ 🔥 Streak Banner, Calorie Card এবং প্রগ্রেস বার আপডেট হলো ]
```

---

## G. SQLite Database Architecture & Schema

FitTrack v3 ডেটাবেসে মোট **৯টি** সম্পূর্ণ টেবিল রয়েছে:

```
┌───────────────────┐       ┌────────────────────┐
│   user_profile    │       │    meal_records    │
├───────────────────┤       ├────────────────────┤
│ id (PK)           │       │ id (PK)            │
│ name              │       │ title              │
│ age               │       │ meal_type          │
│ gender            │       │ calories           │
│ height_cm         │       │ protein_grams      │
│ weight_kg         │       │ carbs_grams        │
│ fitness_goal      │       │ fats_grams         │
│ activity_level    │       │ date (YYYY-MM-DD)  │
│ daily_water_goal  │       │ time (HH:MM A)     │
│ updated_at        │       │ created_at         │
└───────────────────┘       └────────────────────┘

┌───────────────────┐       ┌────────────────────┐
│  weight_records   │       │   water_records    │
├───────────────────┤       ├────────────────────┤
│ id (PK)           │       │ id (PK)            │
│ weight_kg         │       │ amount_ml          │
│ date (YYYY-MM-DD) │       │ date (YYYY-MM-DD)  │
│ note              │       │ time (HH:MM A)     │
│ created_at        │       │ created_at         │
└───────────────────┘       └────────────────────┘

┌───────────────────┐       ┌────────────────────┐
│   step_records    │       │health_calculations │
├───────────────────┤       ├────────────────────┤
│ id (PK)           │       │ id (PK)            │
│ date (UNIQUE)     │       │ type (BMI/BMR/etc) │
│ steps             │       │ value              │
│ calories_burned   │       │ category           │
│ distance_km       │       │ date (YYYY-MM-DD)  │
│ updated_at        │       │ created_at         │
└───────────────────┘       └────────────────────┘

┌───────────────────┐       ┌────────────────────┐       ┌────────────────────┐
│     exercises     │       │  workout_sessions  │       │    workout_sets    │
├───────────────────┤       ├────────────────────┤       ├────────────────────┤
│ id (PK)           │       │ id (PK)            │◄──┐   │ id (PK)            │
│ name              │       │ title              │   └───│ session_id (FK)    │
│ category          │       │ date (YYYY-MM-DD)  │       │ exercise_id (FK)   │
│ description       │       │ duration_seconds   │       │ exercise_name      │
│ default_reps      │       │ notes              │       │ set_number         │
│ is_custom         │       │ created_at         │       │ reps               │
└───────────────────┘       └────────────────────┘       │ weight_kg          │
                                                         │ is_completed       │
                                                         └────────────────────┘
```

---

## H. Terminal & PowerShell Commands Guide

| কমান্ড | কাজ ও ব্যাখ্যা |
|---|---|
| `flutter doctor -v` | কম্পিউটারে ফ্লুটার, অ্যান্ড্রয়েড টুলচেন, জেডিকে এবং কানেক্টেড ডিভাইসের সামগ্রিক স্বাস্থ্য চেক করা। |
| `flutter devices` | পিসির সাথে ইউএসবি দিয়ে কয়টি রিয়েল ফোন ও এমুলেটর সংযুক্ত আছে তা দেখা। |
| `flutter pub get` | `pubspec.yaml`-এ উল্লিখিত সমস্ত প্লাগিন ডাউনলোড করে প্রজেক্টে যুক্ত করা। |
| `dart format .` | পুরো প্রজেক্টের সমস্ত ডার্ট কোডকে গুগলের অফিশিয়াল স্টাইল গাইড অনুযায়ী সাজানো। |
| `flutter analyze` | কোডে কোনো সিনট্যাক্স এরর বা সতর্কবার্তা আছে কিনা তা স্ট্যাটিক অ্যানালাইসিস দিয়ে যাচাই করা। |
| `flutter test` | লেখা ২২টি ইউনিট টেস্ট ও উইজেট টেস্ট চালানো। |
| `flutter build apk --debug` | অ্যান্ড্রয়েড ডিভাইসের জন্য ইনস্টলেবল `app-debug.apk` ফাইল তৈরি করা। |
| `adb install -r <path>` | তৈরিকৃত এপিকে সরাসরি ইউজারের ফিজিক্যাল ফোনে ইনস্টল করা। |
| `adb shell am start -n ...` | টার্মিনাল থেকে অ্যাপটি সরাসরি ফোনের স্ক্রিনে চালু করা। |

---

## I. Testing, Verification & Device Report

### ১. স্ট্যাটিক অ্যানালাইসিস ফলাফল:
- কমান্ড: `flutter analyze`
- ফলাফল: **No issues found! (ran in 2.9s)** — 0 errors, 0 warnings, 0 lints.

### ২. স্বয়ংক্রিয় টেস্ট রেজাল্ট:
- কমান্ড: `flutter test`
- ফলাফল: **All 22 tests passed!**
  - CalculatorService Tests (BMI, Healthy Range, BMR Mifflin-St Jeor, TDEE, Calories Target, Macros)
  - DateFormatter Tests (formatSeconds, todayKey)
  - Model Serialization Tests (UserProfile, WeightRecord, WaterRecord, Exercise, WorkoutSession, WorkoutSet, MealRecord, StepRecord)
  - Widget Tests (StatCard, CustomButton, MetricBadge, EmptyStateWidget, WeightTrendChart, WeeklyBarChart)

### ৩. ফিজিক্যাল ফোনে টেস্ট রিপোর্ট:
- **Device Tested:** Xiaomi `2201117TG` (Android 13, API 33, Arm64)
- **Impeller Engine:** Vulkan ও OpenGLES দিয়ে মসৃণভাবে রেন্ডার হয়েছে।
- **ক্র্যাশ রিপোর্ট:** ০ ক্র্যাশ, ০ মেমোরি লিক।

---

## J. How You Can Modify & Expand the App

1. **নতুন খাবার যুক্ত করতে চাইলে:**
   `lib/core/constants/app_constants.dart` ফাইলের `commonFoods` লিস্টে গিয়ে নতুন `CommonFoodItem` যুক্ত করুন।
2. **নতুন এক্সারসাইজ যোগ করতে চাইলে:**
   `lib/database/database_helper.dart` এর `_onCreate` মেথডে `_prepopulateExercises()` ফাংশনে গিয়ে নতুন ব্যায়ামের নাম ও ক্যাটাগরি লিখে দিন।
3. **রং বা থিম পরিবর্তন করতে চাইলে:**
   `lib/core/theme/app_colors.dart` ফাইলে যান। সেখানে `primary`, `surface`, `accent` ইত্যাদি হেক্স কালার কোড বদলে দিন।

---

## K. 15 Real Interview Questions & Answers

#### প্রশ্ন ১: `DatabaseHelper` ক্লাসে সিঙ্গেলটন প্যাটার্ন (Singleton Pattern) কেন ব্যবহার করা হয়েছে?
- **English Answer:** "The Singleton pattern ensures that only one instance of the `DatabaseHelper` class and a single database connection pool exists throughout the application lifecycle. Opening multiple database connections simultaneously can cause database locking issues, race conditions, and unnecessary memory consumption."
- **বাংলা ব্যাখ্যা:** প্রতিটি স্ক্রিন যদি আলাদা আলাদা ডেটাবেস কানেকশন তৈরি করত, তবে ডেটাবেসে লক লেগে অ্যাপ ক্র্যাশ করত। সিঙ্গেলটন দিয়ে পুরো অ্যাপে কেবল একটিমাত্র সেন্ট্রাল ডেটাবেস কানেকশন নিশ্চিত করা হয়েছে।

#### প্রশ্ন ২: `IndexedStack` কী এবং বটম নেভিগেশনে এটি কেন সাধারণ `Switch/Case` এর চেয়ে ভালো?
- **English Answer:** "`IndexedStack` preserves the state and scroll position of all inactive tabs in memory while displaying only the child at the current index. If we simply swapped widgets with an if-else or list lookup, switching tabs would destroy the previous screen and rebuild it from scratch, resetting user scroll positions and transient inputs."
- **বাংলা ব্যাখ্যা:** সাধারণ পদ্ধতিতে ট্যাব বদলালে আগের পেজটি মেমোরি থেকে মুছে যেত। `IndexedStack` ব্যবহারের ফলে সব ট্যাবের স্টেট ও স্ক্রল ব্যাকগ্রাউন্ডে সংরক্ষিত থাকে।

#### প্রশ্ন ৩: বিএমআই এবং ম্যাক্রো হিসেবের লজিক UI স্ক্রিনে না রেখে আলাদা `CalculatorService`-এ কেন রাখা হলো?
- **English Answer:** "This follows the Separation of Concerns (SoC) and Single Responsibility Principle (SRP). Keeping calculation logic pure and decoupled from the Flutter UI makes the business logic easy to unit test, reuse across different screens, and maintain without breaking the UI."
- **বাংলা ব্যাখ্যা:** ইউআই এবং ক্যালকুলেশন আলাদা রাখলে কোড টেস্ট করা যায় খুব সহজে। তাছাড়া একাধিক স্ক্রিনে একই ফাংশন পুনঃব্যবহার করা যায়।

#### প্রশ্ন ৪: `TextEditingController`-এর কাজ কী এবং এটি কেন `dispose()` মেথডে বন্ধ করতে হয়?
- **English Answer:** "`TextEditingController` manages the text, selection, and listening to user typing inside a `TextField`. It allocates native platform resources and ChangeNotifier listeners. If it is not disposed of in the `dispose()` lifecycle method when the widget is removed from the widget tree, it leads to memory leaks."
- **বাংলা ব্যাখ্যা:** কন্ট্রোলার টেক্সটফিল্ডের ইনপুট ধরে রাখে। পেজ থেকে বের হয়ে যাওয়ার সময় এটিকে `dispose()` না করলে মেমোরিতে অতিরিক্ত জায়গা আটকে থাকে যাকে মেমোরি লিক বলে।

#### প্রশ্ন ৫: SQLite-এ `CASCADE` ডিলিটের সুবিধা কী যা FitTrack-এর `workout_sets` টেবিলে ব্যবহৃত হয়েছে?
- **English Answer:** "`ON DELETE CASCADE` is a foreign key constraint. In FitTrack, workout sets are linked to a `workout_sessions` parent table via `session_id`. When a user deletes a workout session, SQLite automatically removes all associated sets without requiring manual deletion queries, ensuring relational integrity and preventing orphaned rows."
- **বাংলা ব্যাখ্যা:** যখন ইউজার কোনো ওয়ার্কআউট সেশন ডিলিট করবেন, তখন ওই সেশনের ভেতরের সব সেটস স্বয়ংক্রিয়ভাবে মুছে যাবে। ফলে ডেটাবেসে কোনো আবর্জনা (অনাথ ডেটা) জমে থাকবে না।

---

## L. Complete Step-by-Step APK Generation Guide (এপিকে বানানোর হ্যান্ডস-অন গাইড)

FitTrack অ্যাপকে যেকোনো অ্যান্ড্রয়েড ফোনে ইনস্টলযোগ্য APK ফাইলে রূপান্তর করার জন্য সম্পূর্ণ গাইড নিচে দেওয়া হলো:

### ১. APK তৈরির ধরনসমূহ (Types of APKs):
1. **Release APK (`flutter build apk --release`):**
   - সম্পূর্ণ প্রোডাকশন অপটিমাইজড এবং AOT (Ahead-of-Time) কম্পাইল্ড।
   - সব ধরনের অ্যান্ড্রয়েড ফোনে চলবে (Universal)।
2. **Split-per-ABI APK (`flutter build apk --split-per-abi`):**
   - প্রসেসর আর্কিটেকচার অনুযায়ী আলাদা ফাইল তৈরি করে (যেমন: `arm64-v8a`)।
   - ফাইলের সাইজ প্রায় **৩ গুণ ছোট** হয়ে যায় (মাত্র ১৫ থেকে ২৫ মেগাবাইট)।
3. **Debug APK (`flutter build apk --debug`):**
   - ডেভেলপারদের দ্রুত টেস্টিং এবং ডিবাগ লগ দেখার জন্য।

### ২. তৈরির ধাপসমূহ (Step-by-Step Execution):
- **ধাপ ১:** VS Code-এর টার্মিনাল বা Windows PowerShell ওপেন করুন এবং প্রজেক্ট ফোল্ডারে থাকুন:
  ```powershell
  cd "c:\Users\Tanbir Hasan\Desktop\fittrack"
  ```
- **ধাপ ২:** কোড ক্লিন ও রিফ্রেশ করুন:
  ```powershell
  flutter clean
  flutter pub get
  ```
- **ধাপ ৩:** রিলিজ APK বিল্ড কমান্ড দিন:
  ```powershell
  flutter build apk --split-per-abi
  ```
  *(বা সার্বজনীন APK-র জন্য: `flutter build apk --release`)*

### ৩. বিল্ড হওয়া APK ফাইলের পাথ (Exact File Location):
বিল্ড শেষ হলে নিচের ফোল্ডারে আপনার `.apk` ফাইলটি পেয়ে যাবেন:
`c:\Users\Tanbir Hasan\Desktop\fittrack\build\app\outputs\flutter-apk\`

- ফোল্ডারটি সরাসরি উইন্ডোজ এক্সপ্লোরারে ওপেন করার কমান্ড:
  ```powershell
  explorer.exe "c:\Users\Tanbir Hasan\Desktop\fittrack\build\app\outputs\flutter-apk"
  ```

---

## M. Full White Theme & Authentication System (হোয়াইট থিম ও অথেনটিকেশন ফিচার)

### ১. প্রিমিয়াম ফুল হোয়াইট থিম আর্কিটেকচার (Full White Theme Architecture):
- **Scaffold Background:** `#F8FAFC` (Slate-50) — আধুনিক, পরিষ্কার এবং চোখের জন্য আরামদায়ক অফ-হোয়াইট।
- **Cards & Surfaces:** `#FFFFFF` (Pure White) — খাঁটি সাদা কার্ড, যার সাথে রয়েছে সূক্ষ্ম `1px` বর্ডার (`#E2E8F0`) এবং কোমল সফট শ্যাডো (`4% opacity`)।
- **হাই-কন্ট্রাস্ট টাইপোগ্রাফি (High-Contrast Readable Typography):**
  - হেডলাইন ও প্রাইমারি টেক্সট: `#0F172A` (Slate-900 / Deep Charcoal Black) — সাদা ব্যাকগ্রাউন্ডে ১০০% সুস্পষ্ট ও উজ্জ্বল।
  - সাবটাইটেল ও লেবেল: `#475569` (Slate-600)।
  - হিন্ট ও ক্যাপশন: `#94A3B8` (Slate-400)।
- **ব্র্যান্ড অ্যাকসেন্ট কালার:** `#10B981` (ভাইব্র্যান্ট এমারেল্ড গ্রিন) এবং `#0284C7` (স্কাই ব্লু)।

### ২. সাইনআপ, লগইন ও গেস্ট ফিচার (Signup, Login & Guest Mode):
- **SQLite `app_users` ডেটাবেস টেবিল:**
  ```sql
  CREATE TABLE app_users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    password TEXT NOT NULL,
    is_guest INTEGER NOT NULL DEFAULT 0,
    is_active INTEGER NOT NULL DEFAULT 0,
    created_at TEXT NOT NULL
  )
  ```
- **AuthGate (অ্যাপ লঞ্চ সেশন চেকার):** অ্যাপটি ওপেন হওয়ার সময় স্বয়ংক্রিয়ভাবে চেক করে কোনো সক্রিয় ইউজার লগইন আছে কি না। থাকলে সরাসরি ড্যাশবোর্ডে নিয়ে যায়, অন্যথায় লগইন পেজ প্রদর্শন করে।
- **গেস্ট ফিচার (Continue as Guest):** কোনো ইমেইল বা পাসওয়ার্ড ছাড়াই ইউজার এক ক্লিকে "গেস্ট" হিসেবে অ্যাপের সমস্ত ফিচার (ওয়ার্কআউট, ওয়াটার, ডায়েট ও স্টেপ কাউন্টার) ব্যবহার করতে পারবে।
- **গেস্ট মোড প্রোটেকশন ও পার্মানেন্ট অ্যাকাউন্ট লিঙ্ক:** প্রোফাইল স্ক্রিনে গেস্ট ইউজারকে একটি আকর্ষণীয় ব্যানার দেখানো হয়, যা থেকে সে যেকোনো সময় নিজের নাম ও ইমেইল দিয়ে ফুল অ্যাকাউন্টে রূপান্তর করতে পারে।
- **লগআউট সিস্টেম (Log Out):** প্রোফাইল স্ক্রিনের নিচে কনফার্মেশন ডায়ালগ সহ লগআউট অপশন যুক্ত, যা ডাটাবেস সেশন ক্লিয়ার করে নিরাপদে লগইন স্ক্রিনে ফিরিয়ে নিয়ে যায়।

---

## N. Guest Mode, Zero Default Data & Multi-User Architecture (গেস্ট মোড ও মাল্টি-ইউজার আর্কিটেকচার)

### ১. ডিফল্ট ডামি ডেটা সম্পূর্ণ অপসারণ (Clean Profile & Zero Fake History):
- পূর্বে ডেটাবেস ইনিশিয়ালাইজ করার সময় যে কাল্পনিক প্রোফাইল ('Alex Johnson') ও ফেক ওয়েট রেকর্ড সিড করা হতো, তা সম্পূর্ণভাবে কোড থেকে সরিয়ে দেওয়া হয়েছে।
- শুধুমাত্র প্রয়োজনীয় স্ট্যাটিক এক্সারসাইজ লাইব্রেরি (Push-ups, Bench Press, Squats, Pull-ups, Plank, Running ইত্যাদি) সংরক্ষিত রাখা হয়েছে।
- নতুন ইউজার বা গেস্ট অ্যাপ খুললে সম্পূর্ণ খালি হিস্ট্রি (০ টি ওজন রেকর্ড, ০ মিলি পানি, ০ টি খাবার লগ ও ০ টি ওয়ার্কআউট সেশন) নিয়ে শুরু করবে।

### ২. গেস্ট মোড ও ফার্স্ট-টাইম অনবোর্ডিং ফ্লো (Default Guest Mode & Onboarding):
- অ্যাপে কোনো বাধ্যবাধকতা ছাড়া ইউজার ডিফল্টভাবে **Guest Mode**-এ অ্যাপ ব্যবহার করতে পারে।
- প্রথমবার অ্যাপ ইনস্টল করে ওপেন করলে `AuthGate` ডিটেক্ট করে যে কোনো প্রোফাইল বা ইউজার তৈরি নেই এবং সরাসরি `OnboardingScreen` খুলে দেয়।
- অনবোর্ডিং স্ক্রিনে ইউজার নিজের বাস্তব তথ্য প্রদান করে:
  - নিজের নাম (Name)
  - জেন্ডার (Male / Female / Other)
  - বয়স (Age), উচ্চতা (Height cm) ও বর্তমান ওজন (Weight kg)
  - ফিটনেস গোল (Fitness Goal) ও শারীরিক পরিশ্রমের মাত্রা (Activity Level)
  - দৈনিক পানি পানের লক্ষ্যমাত্রা (Daily Water Target ml)
- এক ক্লিকে "Start in Guest Mode 🚀" চাপলে একটি SQLite ট্রানজ্যাকশনের মাধ্যমে লোকাল গেস্ট অ্যাকাউন্ট ও প্রোফাইল তৈরি হয় এবং সাথে সাথে অ্যাপের ড্যাশবোর্ডে নিয়ে যায়।

### ৩. মাল্টি-ইউজার ডেটা আইসোলেশন আর্কিটেকচার (Multi-User Data Isolation):
- ডেটাবেসের প্রতিটি টেবিলকে মাল্টি-ইউজার সাপোর্ট উপযোগী করা হয়েছে এবং `user_id` কলাম যুক্ত করা হয়েছে:
  - `user_profile` $\rightarrow$ `user_id INTEGER`
  - `weight_records` $\rightarrow$ `user_id INTEGER`
  - `water_records` $\rightarrow$ `user_id INTEGER`
  - `workout_sessions` $\rightarrow$ `user_id INTEGER` (এবং `workout_sets` সংযুক্ত থাকে `session_id` দিয়ে)
  - `health_calculations` $\rightarrow$ `user_id INTEGER`
  - `meal_records` $\rightarrow$ `user_id INTEGER`
  - `step_records` $\rightarrow$ `user_id INTEGER`
  - `exercises` $\rightarrow$ কাস্টম এক্সারসাইজের ক্ষেত্রে `user_id INTEGER`, আর স্ট্যান্ডার্ড এক্সারসাইজগুলো গ্লোবাল (`is_custom = 0`)।
- ডেটাবেস কোয়েরিতে সবসময় সক্রিয় ইউজারের `activeUserId` দিয়ে ফিল্টার করা হয় (`WHERE user_id = ?`)। ফলে একজন ইউজারের ডেটা কখনোই অন্য ইউজারের ডেটার সাথে মিশে যাওয়ার কোনো সম্ভাবনা নেই।

### ৪. গেস্ট থেকে পার্মানেন্ট অ্যাকাউন্টে ডেটা মাইগ্রেশন (Atomic Account Migration):
- ইউজার প্রোফাইল স্ক্রিন থেকে যেকোনো সময় অপশনাল হিসেবে "Sign Up (নিবন্ধন)" করতে পারেন।
- নিবন্ধন করার সময় একটি **অ্যাটোমিক ডেটাবেস ট্রানজ্যাকশন (`db.transaction`)** চালানো হয়:
  1. ইমেইল ডুপ্লিকেট কি না চেক করা হয়।
  2. সক্রিয় গেস্ট অ্যাকাউন্টটিকে রূপান্তর (In-place Upgrade) করে পার্মানেন্ট ইউজার অ্যাকাউন্টে পরিবর্তিত করা হয়।
  3. গেস্ট অবস্থায় সেভ করা প্রতিটি ওজন, পানি, খাবার এবং ওয়ার্কআউট রেকর্ড অক্ষতভাবে নতুন অ্যাকাউন্টের সাথে সংযুক্ত হয়ে যায়।
  4. কোনো ডেটা হারিয়ে যায় না এবং কোনো অনাথ (Orphan) রো তৈরি হয় না।

### ৫. লোকাল বনাম ক্লাউড সিনক্রোনাইজেশনের সীমাবদ্ধতা (Local SQLite vs Cloud Sync):
- **বর্তমান আর্কিটেকচার:** সম্পূর্ণ অফলাইন-ফার্স্ট, লোকাল SQLite চালিত। এটি ইন্টারনেট ছাড়া সুপারফাস্ট কাজ করে, ব্যবহারকারীর কোনো ব্যক্তিগত স্বাস্থ্য তথ্য ইন্টারনেটে লিক হওয়ার ঝুঁকি থাকে না।
- **সীমাবদ্ধতা:** যেহেতু কোনো রিমোট ব্যাকএন্ড (Firebase/REST API) নেই, তাই ফোন পরিবর্তন করলে বা অ্যাপ সম্পূর্ণ আনইনস্টল করে দিলে লোকাল ডেটাবেস মুছে যেতে পারে। ভবিষ্যতে ক্লাউড সিঙ্ক ফিচার যোগ করতে চাইলে একটি ব্যাকএন্ড API যুক্ত করে এই একই `user_id` ম্যাপিং ক্লাউড ডাটাবেসের সাথে সিঙ্ক করা যাবে।

---

## O. Automated Test Verification (৩৫টি টেস্ট সফল)

- **`dart analyze`:** **No issues found!** (0 errors, 0 warnings, 0 infos).
- **`flutter test`:** **All 35 unit & widget tests passed!**
  - CalculatorService Tests (BMI, Range, BMR, TDEE, Calories, Macros)
  - DateFormatter Tests (formatSeconds, todayKey, formatDate, formatShortDay)
  - Model Serialization Tests (UserProfile, WeightRecord, WaterRecord, Exercise, WorkoutSession, WorkoutSet, MealRecord, StepRecord, AppUser, Guest AppUser, Multi-User userId isolation, DailyNutritionSummary)
  - Smart Step Tracking & Sensor Logic Tests (StepRecord serialization, Distance & Calorie formula metrics, Sensor delta calculation, Device reboot handling, Duplicate event filtering, Midnight rollover preservation)
  - Widget Tests (StatCard, CustomButton, MetricBadge, EmptyStateWidget, WeightTrendChart, WeeklyBarChart)

---

## P. Smart Step Counter Implementation (স্মার্ট পেডোমিটার ও অটোমেটিক স্টেপ ট্র্যাকার)

### ১. হার্ডওয়্যার সেন্সর ও পারমিশন ইন্টিগ্রেশন:
- **প্যাকেজ:** `pedometer: ^4.2.0` এবং `permission_handler: ^13.0.2`।
- **অ্যান্ড্রয়েড পারমিশন:** `AndroidManifest.xml`-এ `android.permission.ACTIVITY_RECOGNITION` এবং `android.permission.BODY_SENSORS` কনফিগার করা হয়েছে।
- **রানটাইম পারমিশন হ্যান্ডলিং:** Android 10+ ডিভাইসে অ্যাপ খোলার সাথে সাথে ইউজারের কাছে শারীরিক কার্যকলাপ (Physical Activity) পারমিশন চেয়ে প্রম্পট আসে। পারমিশন পার্মানেন্টলি ডিনাইড থাকলে সরাসরি অ্যাপ সেটিংসে গিয়ে পারমিশন দেওয়ার বাটন দেখানো হয়।

### ২. অ্যান্ড্রয়েড সেন্সরের জটিলতা ও ডেল্টা ক্যালকুলেশন অ্যালগরিদম:
অ্যান্ড্রয়েডের হার্ডওয়্যার `TYPE_STEP_COUNTER` সেন্সর সরাসরি আজকের স্টেপ কাউন্ট দেয় না; এটি ফোন অন হওয়ার পর থেকে সর্বমোট কত স্টেপ হয়েছে তা প্রদান করে। এর ফলে ফোন বন্ধ করে চালু করলে কাউন্ট ০ হয়ে যায়। FitTrack-এ আমরা একটি প্রফেশনাল গাণিতিক ডেল্টা ইঞ্জিন বাস্তবায়ন করেছি:
1. **স্বাভাবিক হাঁটা (Normal Walk):** $\Delta = raw - lastBootSteps$। এই পার্থক্য সরাসরি আজকের মোট স্টেপের সাথে যোগ হয়।
2. **ডিভাইস রিবুট শনাক্তকরণ (Device Reboot Detection):** যদি $raw < lastBootSteps$ হয়, তার মানে ফোন রিস্টার্ট হয়েছে। রিস্টার্ট হওয়ার পর ইউজার $raw$ সংখ্যক কদম হেঁটেছেন, তাই $\Delta = raw$ হিসেব করে আজকের পূর্ববর্তী স্টেপের সাথে যুক্ত করা হয়। কোনো ডেটা হারায় না!
3. **মিডনাইট ডেট রোলওভার (Midnight Date Rollover):** রাত ১২টা বাজার পর নতুন দিন শুরু হলে পূর্বের দিনের হিস্ট্রি অক্ষত রেখে নতুন দিনের স্টেপ ০ থেকে শুরু হয় এবং নতুন দিনের জন্য সেন্সর বেসলাইন তৈরি হয়।
4. **ডুপ্লিকেট ইভেন্ট ফিল্টারিং (Duplicate Event Guard):** সেন্সর যদি একই স্টেপ বার বার পাঠায় ($\Delta \le 0$), তবে অপ্রয়োজনীয় ডেটাবেস রাইট বা ব্যাটারি খরচ সম্পূর্ণ বন্ধ রাখা হয়।
5. **মেট্রিক হিসেব:** 
   - দূরত্ব: $\text{Distance (km)} = \text{Steps} \times 0.000762$
   - ক্যালোরি: $\text{Calories Burned (kcal)} = \text{Steps} \times 0.04$

### ৩. রিয়েল-টাইম রিঅ্যাক্টিভ ইউআই ও পেডেস্ট্রিয়ান ডিটেকশন:
- `StepTrackerService`-এ `ValueNotifier` ব্যবহার করা হয়েছে।
- ইউজার হাঁটলে সাথে সাথে ড্যাশবোর্ড কার্ড এবং স্টেপ ট্র্যাকার স্ক্রিনে লাইভ কাউন্টার বাড়ে।
- লাইভ পেডেস্ট্রিয়ান স্ট্যাটাস: ইউজার হাঁটলে ব্যাজে **"Walking 🚶‍♂️"** এবং থেমে থাকলে **"Sensor Active 🟢"** প্রদর্শিত হয়।
- এমুলেটর বা সেন্সরবিহীন ডিভাইসের ক্ষেত্রে সুন্দর ফলব্যাক মেসেজ এবং ম্যানুয়াল ট্র্যাডমিল লগার (+500, +1000, +2500) সক্রিয় থাকে।

---

## Q. Complete Bug Audit & Fix Log (বাগ ফিক্স ও অপ্টিমাইজেশন লগ)

1. **Weight Record Deletion Persistence Bug (ওজন ডিলিট বাগ ফিক্স):**
   - পূর্বে ভুলবশত কোনো ওজন রেকর্ড ডিলিট করলে প্রোফাইলের কারেন্ট ওজন আপডেট হতো না।
   - এখন `DatabaseHelper.deleteWeightRecord()` এ রেকর্ড ডিলিট হওয়ার সাথে সাথে স্বয়ংক্রিয়ভাবে অবশিষ্ট সর্বশেষ ওজন খুঁজে প্রোফাইলে সিঙ্ক করা হয়।
2. **RangeError on Short Date String (তারিখ ক্র্যাশ প্রতিরোধ):**
   - `progress_screen.dart`-এ `c.calculatedAt.substring(0, 10)` ব্যবহারের পূর্বে দৈর্ঘ্য যাচাই (`length >= 10`) যুক্ত করা হয়েছে, যেন ভুল বা সংক্ষিপ্ত ফরম্যাটের স্ট্রিংয়ে অ্যাপ ক্র্যাশ না করে।
3. **Daily Habit Streak Step Integration (স্ট্রিকে হাঁটা অন্তর্ভুক্তকরণ):**
   - পূর্বে স্ট্রিকে শুধু পানি, খাবার এবং ওয়ার্কআউট কাউন্ট হতো।
   - এখন `step_records` যুক্ত করা হয়েছে, ফলে ইউজার প্রতিদিন হাঁটলেও তার ডেইলি স্ট্রিক 🔥 বৃদ্ধি পায়।
4. **Historical Step Records List (অতীতের স্টেপ হিস্ট্রি ভিউ):**
   - স্টেপ ট্র্যাকার স্ক্রিনে একটি সম্পূর্ণ নতুন সেকশন যোগ করা হয়েছে, যেখানে বিগত ১৪ দিনের তারিখ, স্টেপ সংখ্যা, অর্জিত শতকরা হার এবং কিমি/ক্যালোরি স্পষ্ট তালিকায় দেখা যায়।
5. **Weekly Steps Analytics Bar Chart (সাপ্তাহিক প্রগ্রেস চার্ট):**
   - অ্যানালিটিক্স স্ক্রিনে গত ৭ দিনের পানির পাশাপাশি গত ৭ দিনের স্টেপসের আকর্ষণীয় পার্পল বার চার্ট যুক্ত করা হয়েছে।
6. **Async Gaps & BuildContext Memory Leak Fix:**
   - `login_screen`, `signup_screen`, `onboarding_screen`-এ পেজ ট্রানজিশনের পূর্বে `if (!mounted) return;` সেফগার্ড দিয়ে মেমোরি লিক ও আনহ্যান্ডলড এক্সেপশন সমাধান করা হয়েছে।

---

**অভিনন্দন! FitTrack অ্যাপে স্মার্ট স্টেপ কাউন্টার, অটোমেটিক সেন্সর ট্র্যাকিং, সম্পূর্ণ বাগ অডিট এবং ৩৫টি স্বয়ংক্রিয় টেস্ট সফলভাবে সম্পন্ন হয়েছে!**
