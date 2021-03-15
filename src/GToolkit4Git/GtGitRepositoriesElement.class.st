Class {
	#name : #GtGitRepositoriesElement,
	#superclass : #BlElement,
	#traits : 'TGtGitWithRepositoriesViewModel + TBrLayoutResizable',
	#classTraits : 'TGtGitWithRepositoriesViewModel classTrait + TBrLayoutResizable classTrait',
	#instVars : [
		'listElement',
		'toolbarElement'
	],
	#category : #'GToolkit4Git-UI - Element'
}

{ #category : #initialization }
GtGitRepositoriesElement >> defaultLayout [
	^ BlLinearLayout vertical
]

{ #category : #'private - actions' }
GtGitRepositoriesElement >> fetchAllRepositoriesFrom: aButton [
	self repositoriesViewModel fetchAllSource: nil.
]

{ #category : #initialization }
GtGitRepositoriesElement >> initialize [
	super initialize.
	self initializeToolbar.
	self initializeListElement.
	
	self addChild: self toolbarElement as: #toolbar.
	self addChild: self listElement as: #list.
	
	self matchParent.
]

{ #category : #initialization }
GtGitRepositoriesElement >> initializeListElement [
	listElement := BrColumnedList new.
	
	listElement column
		title: 'Repository';
		cellStencil: [ self newCellLabel ];
		dataBinder: [ :aCellElement :aRepository | 
			aCellElement text: aRepository name ].
		
	listElement column
		title: 'Branch';
		cellStencil: [ self newCellLabel ];
		dataBinder: [ :aCellElement :aRepository | 
			aCellElement text: aRepository headDescription ].
		
	listElement column
		title: 'Status';
		cellStencil: [ self newCellLabel ];
		dataBinder: [ :aCellElement :aRepository | 
			aCellElement text: aRepository status ]
]

{ #category : #initialization }
GtGitRepositoriesElement >> initializeToolbar [
	toolbarElement := BrToolbar new
		look: (BrGlamorousToolbarLook new spacing: 0);
		vFitContent;
		hMatchParent.
	
	toolbarElement
		addItem: (BrLabel new
			look: (BrGlamorousLabelLook new 
				bold; 
				labelDo: [ :aLabel | aLabel padding: BlInsets empty ]);
			beHugeSize;
			text: 'Git Repositories');
		addItem: (BrFrame new
			vFitContent;
			hMatchParent);
		addItem: (BrButton new
			look: BrGlamorousButtonWithIconLook;
			icon: BrGlamorousVectorIcons refresh;
			label: 'Fetch all repositories';
			action: [ :aButton | self fetchAllRepositoriesFrom: aButton ]);
		addItem: (BrButton new
			look: BrGlamorousButtonWithIconLook;
			icon: BrGlamorousVectorIcons add;
			label: 'Add repository')
]

{ #category : #'private - accessing' }
GtGitRepositoriesElement >> listElement [
	<return: #BrColumnedList>
	^ listElement
]

{ #category : #'private - instance creation' }
GtGitRepositoriesElement >> newCellLabel [
	^ BrLabel new
		look: BrGlamorousLabelLook new;
		hMatchParent;
		vFitContent
]

{ #category : #'api - repositories view model' }
GtGitRepositoriesElement >> onRepositoriesViewModelChanged [
	"Is sent when a new repositories view model is assigned to the element.
	Note: #onRepositoriesViewModelChanged is sent before #subscribeToRepositoriesViewModel
	which means that if you perform any operation that triggers an announcement it will be ignored because the receiver
	didn't get a chance to subscribe to any announcement. Override #onPostRepositoriesViewModelChanged if you
	wish to perform an operation that requires an announcement, but keep in mind that this is not the most efficient way"

	self updateElement.
]

{ #category : #'private - accessing' }
GtGitRepositoriesElement >> toolbarElement [
	<return: #BrToolbar>
	^ toolbarElement
]

{ #category : #'private - updating' }
GtGitRepositoriesElement >> updateElement [
	self listElement items: self repositoriesViewModel repositories copy.
]
