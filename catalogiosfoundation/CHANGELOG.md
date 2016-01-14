## 2.1

Bug fixes:
	- CarouselMainViewController::resizeView - adjusting size based on yOffset.
		issue with statusBarFrame call on rotation.
	
iOS7 Readiness:
	- Converted CatalogFoundation Objective-C to ARC (Automatic Reference Counting)
	- BasicPortfolioDetailViewController changes for iOS7 layout (PortfolioDetailView changes)
	- ResourceItemPreviewView fix vertical label for each preview thumbnail
	- ContentInfoToolbarView layout for portrait and landscape of toolbar buttons

Features:
	- Ability to set main, category, detail screen backgrounds to 
		pre-iOS7 (768x1008, 1024x748) or full screen (768x1024, 1024x768)
	- Turn Reflection on/off through SFAppConfig configuration property
	- Configure whether or not the toolbar for PDF documents auto hides
	- Hide/show features & benefits tabs

Documentation:

