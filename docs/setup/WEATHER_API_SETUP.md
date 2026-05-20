# Weather API Setup

## Step 1: Get OpenWeatherMap API Key

1. Go to [OpenWeatherMap](https://openweathermap.org/api)
2. Click "Sign Up" (free account)
3. Verify your email
4. Go to API keys section
5. Copy your API key

**Free Tier Limits:**
- 1,000 API calls per day
- Current weather data
- More than enough for field use!

## Step 2: Configure Your Project

### Option A: Using Environment Variable (Recommended for now)

For quick testing, you can hardcode the API key temporarily in your code:

```swift
// In your view or service initialization
let weatherService = WeatherService(apiKey: "your_api_key_here")
```

**⚠️ Important:** Remove hardcoded keys before committing to Git!

### Option B: Using Config File (Better for production)

1. Copy `Config.xcconfig.example` to `Config.xcconfig`:
   ```bash
   cd /Users/davidcontreras/AppleXCodeProjects/fieldnote
   cp Config.xcconfig.example Config.xcconfig
   ```

2. Edit `Config.xcconfig` and add your API key:
   ```
   WEATHER_API_KEY = your_actual_api_key_here
   ```

3. Add `Config.xcconfig` to `.gitignore` (already done)

4. In Xcode:
   - Select your project
   - Select the `fieldnote` target
   - Go to Build Settings
   - Search for "User-Defined"
   - Add: `WEATHER_API_KEY = $(WEATHER_API_KEY)`

5. Access in code:
   ```swift
   let apiKey = Bundle.main.infoDictionary?["WEATHER_API_KEY"] as? String ?? ""
   ```

## Step 3: Test the Integration

1. Run the app
2. Navigate to New Log tab
3. Grant location permission
4. Weather data should appear after GPS lock

## Troubleshooting

### "Weather API key not configured"
- Make sure you've set the API key
- Check for typos in the key

### HTTP 401 Error
- API key is invalid
- Go to OpenWeatherMap dashboard and verify your key is active
- New keys can take up to 10 minutes to activate

### HTTP 429 Error
- You've exceeded the free tier limit (1000 calls/day)
- Wait until tomorrow or upgrade plan

### Weather not loading
- Check if location services are working first
- Verify internet connection
- Weather depends on GPS coordinates

## API Response Example

```json
{
  "weather": [
    {
      "main": "Clouds",
      "description": "few clouds",
      "icon": "02d"
    }
  ],
  "main": {
    "temp": 18.5,
    "humidity": 65
  },
  "wind": {
    "speed": 3.2
  }
}
```

## Cache Behavior

Weather data is cached for 10 minutes per location to:
- Reduce API calls
- Improve performance
- Work better in areas with poor connectivity

## Next Steps

Once you have your API key:
1. Add it to the project (Option A or B above)
2. Test in the simulator (use Features → Location → Custom Location)
3. Test on a real device in the field
