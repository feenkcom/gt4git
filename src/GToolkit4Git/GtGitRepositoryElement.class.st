Class {
	#name : #GtGitRepositoryElement,
	#superclass : #BlElement,
	#traits : 'TGtGitWithRepositoryViewModel + TBrLayoutResizable',
	#classTraits : 'TGtGitWithRepositoryViewModel classTrait + TBrLayoutResizable classTrait',
	#instVars : [
		'tabsElement',
		'toolbarElement',
		'labelElement'
	],
	#category : #'GToolkit4Git-UI - Element'
}

{ #category : #initialization }
GtGitRepositoryElement >> defaultLayout [
	^ BlLinearLayout vertical
]

{ #category : #initialization }
GtGitRepositoryElement >> initialize [
	super initialize.
	self initializeToolbarElement.
	
	self addChild: self toolbarElement as: #toolbar.
	
	self matchParent.
]

{ #category : #initialization }
GtGitRepositoryElement >> initializeToolbarElement [
	toolbarElement := BrToolbar new
		look: (BrGlamorousToolbarLook new spacing: 0);
		vFitContent;
		hMatchParent.
	
	toolbarElement
		addItem: (labelElement := BrLabel new
			look: (BrGlamorousLabelLook new 
				bold; 
				labelDo: [ :aLabel | aLabel padding: BlInsets empty ]);
			beHugeSize;
			text: '');
		addItem: (BrFrame new
			vFitContent;
			hMatchParent);
		addItem: (BrButton new
			look: BrGlamorousButtonWithIconLook;
			icon: BrGlamorousVectorIcons refresh;
			label: 'Fetch';
			action: [ :aButton | self fetchAllRepositoriesFrom: aButton ]);
		addItem: (BrButton new
			look: BrGlamorousButtonWithIconLook;
			icon: BrGlamorousVectorIcons add;
			label: 'Something')
]

{ #category : #'private - accessing' }
GtGitRepositoryElement >> labelElement [
	^ labelElement
]

{ #category : #'api - repository view model' }
GtGitRepositoryElement >> onRepositoryViewModelChanged [
	"Is sent when a new repository view model is assigned to the element.
	Note: #onRepositoryViewModelChanged is sent before #subscribeToRepositoryViewModel
	which means that if you perform any operation that triggers an announcement it will be ignored because the receiver
	didn't get a chance to subscribe to any announcement. Override #onPostRepositoryViewModelChanged if you
	wish to perform an operation that requires an announcement, but keep in mind that this is not the most efficient way"

	self labelElement text: self repositoryViewModel name
]

{ #category : #'private - accessing' }
GtGitRepositoryElement >> tabsElement [
	^ tabsElement
]

{ #category : #'private - accessing' }
GtGitRepositoryElement >> toolbarElement [
	^ toolbarElement
]
