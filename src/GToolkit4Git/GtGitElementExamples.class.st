Class {
	#name : #GtGitElementExamples,
	#superclass : #Object,
	#traits : 'TGtExampleAssertable',
	#classTraits : 'TGtExampleAssertable classTrait',
	#category : #'GToolkit4Git-Examples'
}

{ #category : #accessing }
GtGitElementExamples >> cleanUpRepository [
	IceRepository registry
		detect: [ :aRepository | aRepository name = self repositoryName ]
		ifFound: [ :aRepository | 
			aRepository forget.	"Delete all files from disk related to this repository"
			aRepository workingCopy fileSystem ensureDeleteAll ]
]

{ #category : #examples }
GtGitElementExamples >> expandedElement [
	<gtExample>
	| element |
	element := self simpleElement createInPager maximized.
	
	^ element
]

{ #category : #accessing }
GtGitElementExamples >> repositoryName [
	^ 'AAA'
]

{ #category : #examples }
GtGitElementExamples >> scripterOnExpandedElement [
	<gtExample>
	| aScripter |
	
	aScripter := BlScripter new.
	aScripter element: self expandedElement.
	
	^ aScripter
]

{ #category : #examples }
GtGitElementExamples >> scripterOnExpandedElementWithAddDialogOpen [
	<gtExample>
	| aScripter |
	aScripter := self scripterOnExpandedElement.
	aScripter
		clickStep: [ :s | 
			s
				label: 'Click search';
				id: #sidebar;
				id: #toolbar;
				onChildAt: 1;
				onChildAt: 1 ].

	^ aScripter
]

{ #category : #examples }
GtGitElementExamples >> scripterOnExpandedElementWithDeletedRepository [
	<gtExample>
	| aScripter |
	aScripter := self scripterOnExpandedElementWithInitializationDone.
	aScripter
		clickStep: [ :s | 
			s
				label: 'Click on delete button';
				id: #content;
				id: #toolbar;
				onChildAt: 2 ].

	aScripter
		clickStep: [ :s | 
			s
				label: 'Click on checkbox';
				onSpaceRoot;
				id: #'git-repository-removal-checkbox' ].

	aScripter
		clickStep: [ :s | 
			s
				label: 'Click on remove button';
				onSpaceRoot;
				id: #'change-button-action' ].

	aScripter
		checkStep: [ :s | 
			s
				label: 'Check repository';
				satisfies: [ :aChangeView | aChangeView pages last contentElement tool repository isNil ] ].

	^ aScripter
]

{ #category : #examples }
GtGitElementExamples >> scripterOnExpandedElementWithEditedBranch [
	<gtExample>
	| aScripter |
	aScripter := self scripterOnExpandedElementWithExpandedProperties.

	aScripter
		clickStep: [ :s | 
			s
				label: 'Click on branch field';
				id: (GtMagritteFieldElementId new
						description: aScripter element pages first contentElement tool repository branchDescription) ].

	aScripter
		typeStep: [ :s | 
			s
				label: 'Edit branch field';
				text: 'test' ].	"this is a mess, because we're getting everything from elements"
	aScripter
		checkStep: [ :s | 
			s
				label: 'Check branch';
				satisfies: [ :aChangeView | 
					| mementoCache |
					mementoCache := ((((((aChangeView pages last contentElement tool
							childNamed: #content) childNamed: #definitions) childNamed: #content)
							childAt: 1) childAt: 1) userData at: #gtmemento) cache.
					(mementoCache associationsSelect: [ :a | a key label = 'Branch' ]) anyOne
						value valueOrNil currentValue = 'test' ] ].

	^ aScripter
]

{ #category : #examples }
GtGitElementExamples >> scripterOnExpandedElementWithExpandedProperties [
	<gtExample>
	| aScripter |
	aScripter := self scripterOnExpandedElementWithInitializationDone.

	aScripter
		clickStep: [ :s | 
			s
				label: 'Click on expander button';
				id: #content;
				id: #definitions;
				id: #sidebar ].

	^ aScripter
]

{ #category : #examples }
GtGitElementExamples >> scripterOnExpandedElementWithExpandedSearch [
	<gtExample>
	| aScripter |
	aScripter := self scripterOnExpandedElement.
	aScripter
		clickStep: [ :s | 
			s
				label: 'Click search';
				id: #sidebar;
				id: #toolbar;
				onChildAt: 1;
				onChildAt: 3 ].

	^ aScripter
]

{ #category : #examples }
GtGitElementExamples >> scripterOnExpandedElementWithInitializationDialogNavigated [
	<gtExample>
	| aScripter |
	aScripter := self scripterOnExpandedElementWithInitializationDialogOpen.
	aScripter doubleClick
		label: 'Click on directory';
		onSpaceRoot;
		id: #'git-initialize-page';
		onChildAt: 2;
		id: #scrollable;
		onChildAt: 2;
		play.

	^ aScripter
]

{ #category : #examples }
GtGitElementExamples >> scripterOnExpandedElementWithInitializationDialogOpen [
	<gtExample>
	| aScripter |
	aScripter := self scripterOnExpandedElementWithAddDialogOpen.
	(FileLocator imageDirectory / self repositoryName) ensureCreateDirectory.
	aScripter
		clickStep: [ :s | 
			s
				label: 'Click initialization';
				onSpaceRoot;
				id: #'git-initial' ].

	^ aScripter
]

{ #category : #examples }
GtGitElementExamples >> scripterOnExpandedElementWithInitializationDone [
	<gtExample>
	<after: #cleanUpRepository>
	| aScripter |
	aScripter := self scripterOnExpandedElementWithInitializationDialogNavigated.
	aScripter
		clickStep: [ :s | 
			s
				label: 'Click on directory';
				onSpaceRoot;
				id: #'git-initialize-page';
				onChildAt: 3;
				onChildAt: 1 ].	"this will need to be changed once we select correctly"
	aScripter
		checkStep: [ :s | 
			s
				label: 'Check repository';
				satisfies: [ :aChangeView | aChangeView pages last contentElement tool repository isNotNil ] ].

	^ aScripter
]

{ #category : #examples }
GtGitElementExamples >> scripterOnExpandedElementWithSearchResult [
	<noTest>
	<gtExample>
	| aScripter |
	aScripter := self scripterOnExpandedElementWithExpandedSearch.

	aScripter
		checkStep: [ :s | 
			s
				label: 'Check no repository';
				satisfies: [ :aChangeView | aChangeView pages last contentElement tool repository isNil ] ].

	aScripter
		typeStep: [ :s | 
			s
				label: 'Search for GToolkit repository';
				text: 'gtoolkit' ].


	aScripter
		keyPressStep: [ :s | 
			s
				label: 'Select repository';
				key: BlKeyboardKey return ].

	aScripter
		checkStep: [ :s | 
			s
				label: 'Check repository';
				satisfies: [ :aChangeView | aChangeView pages last contentElement tool repository name = 'gtoolkit' ] ].

	^ aScripter
]

{ #category : #examples }
GtGitElementExamples >> scripterOnExpandedElementWithSelectedRepository [
	<gtExample>
	<noTest>
	<after: #cleanUpRepository>
	| aScripter |
	aScripter := self scripterOnExpandedElementWithInitializationDone.

	aScripter
		checkStep: [ :s | 
			s
				label: 'Unselect repository';
				do: [ :aChangeView | 
					aChangeView pages last contentElement tool
						onNavigationModelChange: (GtGitRepositorySelected new repository: nil) ] ].

	aScripter
		checkStep: [ :s | 
			s
				label: 'Check no repository';
				satisfies: [ :aChangeView | aChangeView pages last contentElement tool repository isNil ] ].

	aScripter
		clickStep: [ :s | 
			s
				label: 'Click first repository';
				id: #sidebar;
				id: #content;
				id: #scrollable;
				onChildAt: 1 ].

	aScripter
		checkStep: [ :s | 
			s
				label: 'Check repository selected';
				satisfies: [ :aChangeView | aChangeView pages last contentElement tool repository isNotNil ] ].

	aScripter
		checkStep: [ :s | 
			s
				label: 'Check repository rendering basics (name is shown)';
				satisfies: [ :aChangeView | 
					((aChangeView pages last contentElement tool childNamed: #content)
						childNamed: #toolbar) children first text asString
						= aChangeView pages last contentElement tool repository name ] ].

	^ aScripter
]

{ #category : #examples }
GtGitElementExamples >> simpleElement [
	<gtExample>
	| element |
	element := GtGitElement new.
	
	self assert: element repository equals: nil.
	
	^ element
]
