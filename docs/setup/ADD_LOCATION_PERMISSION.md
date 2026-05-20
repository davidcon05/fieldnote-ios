# How to Add Location Permission (Step-by-Step)

## Method 1: Using Xcode UI (Recommended)

1. **Open your project in Xcode**

2. **In the left sidebar (Project Navigator):**
   - Click on the **blue "fieldnote"** icon at the very top
   - This is your project file (not a folder, the blue document icon)

3. **In the main editor area:**
   - You'll see two sections: PROJECT and TARGETS
   - Under TARGETS, click **"fieldnote"** (should already be selected)

4. **Click the "Info" tab** at the top
   - You'll see tabs: General, Signing & Capabilities, Resource Tags, **Info**, Build Settings, Build Phases, Build Rules
   - Click **Info**

5. **Add the location permission:**
   - Look for "Custom iOS Target Properties" section
   - You'll see a list with columns: Key, Type, Value
   - Hover at the bottom of the list and click the **+** button
   - OR right-click anywhere in the list and select "Add Row"

6. **Fill in the permission:**
   - **Key:** Type `Privacy - Location When In Use Usage Description`
     - (Xcode will auto-complete as you type)
     - OR paste: `NSLocationWhenInUseUsageDescription`
   - **Type:** Should auto-fill as "String"
   - **Value:** `We need your location to tag field observations with GPS coordinates and altitude.`

7. **Save and rebuild:**
   - Press Cmd+B to rebuild
   - Run the app again (Cmd+R)

## What This Does

This adds an entry to your app's Info.plist that tells iOS:
- Why your app needs location access
- What you'll use the location data for
- This text appears in the permission alert to the user

## After Adding the Permission

When you run the app and navigate to New Log:
1. You should see an iOS alert: "fieldnote would like to access your location"
2. Tap **"Allow While Using App"**
3. The Location card should start showing GPS coordinates
4. Weather data should fetch automatically

## Troubleshooting

**If you still don't see the permission alert after adding this:**
1. Clean build folder: Product → Clean Build Folder (Cmd+Shift+K)
2. Reset simulator: Device → Erase All Content and Settings
3. Rebuild and run

**If you accidentally denied permission:**
1. Go to simulator Settings app
2. Scroll to "fieldnote"
3. Tap Location
4. Select "While Using App"
