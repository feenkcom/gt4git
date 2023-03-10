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
	aScripter click
		label: 'Click search';
		id: #sidebar;
		id: #toolbar;
		onChildAt: 1;
		onChildAt: 1;
		play.

	^ aScripter
]

{ #category : #examples }
GtGitElementExamples >> scripterOnExpandedElementWithDeletedRepository [
	<gtExample>
	| aScripter |
	aScripter := self scripterOnExpandedElementWithInitializationDone.
	aScripter click
		label: 'Click on delete button';
		id: #content;
		id: #toolbar;
		onChildAt: 2;
		play.

	aScripter click
		label: 'Click on checkbox';
		onSpaceRoot;
		id: #'git-repository-removal-checkbox';
		play.

	aScripter click
		label: 'Click on remove button';
		onSpaceRoot;
		id: #'change-button-action';
		play.

	aScripter check
		label: 'Check repository';
		satisfies: [ :aChangeView | aChangeView pages last contentElement tool repository isNil ];
		play.

	^ aScripter
]

{ #category : #examples }
GtGitElementExamples >> scripterOnExpandedElementWithEditedBranch [
	<gtExample>
	| aScripter |
	aScripter := self scripterOnExpandedElementWithExpandedProperties.

	aScripter click
		label: 'Click on branch field';
		id: (GtMagritteFieldElementId new
				description: aScripter element pages first contentElement tool repository branchDescription);
		play.

	aScripter type
		label: 'Edit branch field';
		text: 'test';
		play.

	"this is a mess, because we're getting everything from elements"
	aScripter check
		label: 'Check branch';
		satisfies: [ :aChangeView | 
			| mementoCache |
			mementoCache := ((((((aChangeView pages last contentElement tool
					childNamed: #content) childNamed: #definitions) childNamed: #content)
					childAt: 1) childAt: 1) userData at: #gtmemento) cache.
			(mementoCache associationsSelect: [ :a | a key label = 'Branch' ]) anyOne
				value valueOrNil currentValue = 'test' ];
		play.

	^ aScripter
]

{ #category : #examples }
GtGitElementExamples >> scripterOnExpandedElementWithExpandedProperties [
	<gtExample>
	| aScripter |
	aScripter := self scripterOnExpandedElementWithInitializationDone.
	
	aScripter click
		label: 'Click on expander button';
		id: #content;
		id: #definitions;
		id: #sidebar;
		play.

	^ aScripter
]

{ #category : #examples }
GtGitElementExamples >> scripterOnExpandedElementWithExpandedSearch [
	<gtExample>
	| aScripter |
	aScripter := self scripterOnExpandedElement.
	aScripter click
		label: 'Click search';
		id: #sidebar;
		id: #toolbar;
		onChildAt: 1;
		onChildAt: 3;
		play.

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
	aScripter click
		label: 'Click initialization';
		onSpaceRoot;
		id: #'git-initial';
		play.

	^ aScripter
]

{ #category : #examples }
GtGitElementExamples >> scripterOnExpandedElementWithInitializationDone [
	<gtExample>
	<after: #cleanUpRepository>
	| aScripter |
	aScripter := self scripterOnExpandedElementWithInitializationDialogNavigated.
	aScripter click
		label: 'Click on directory';
		onSpaceRoot;
		id: #'git-initialize-page';
		onChildAt: 3;
		onChildAt: 1;
		play.

	"this will need to be changed once we select correctly"
	aScripter check
		label: 'Check repository';
		satisfies: [ :aChangeView | aChangeView pages last contentElement tool repository isNotNil ];
		play.

	^ aScripter
]

{ #category : #examples }
GtGitElementExamples >> scripterOnExpandedElementWithSearchResult [
	<noTest>
	<gtExample>
	| aScripter |
	aScripter := self scripterOnExpandedElementWithExpandedSearch.

	aScripter check
		label: 'Check no repository';
		satisfies: [ :aChangeView | aChangeView pages last contentElement tool repository isNil ];
		play.

	aScripter type
		label: 'Search for GToolkit repository';
		text: 'gtoolkit';
		play.


	aScripter keyPress
		label: 'Select repository';
		key: BlKeyboardKey return;
		play.

	aScripter check
		label: 'Check repository';
		satisfies: [ :aChangeView | aChangeView pages last contentElement tool repository name = 'gtoolkit' ];
		play.

	^ aScripter
]

{ #category : #examples }
GtGitElementExamples >> scripterOnExpandedElementWithSelectedRepository [
	<gtExample>
	<after: #cleanUpRepository>
	| aScripter |
	aScripter := self scripterOnExpandedElementWithInitializationDone.

	aScripter check
		label: 'Unselect repository';
		do: [ :aChangeView | 
			aChangeView pages last contentElement tool
				onNavigationModelChange: (GtGitRepositorySelected new repository: nil) ];
		play.

	aScripter check
		label: 'Check no repository';
		satisfies: [ :aChangeView | aChangeView pages last contentElement tool repository isNil ];
		play.

	aScripter click
		label: 'Click first repository';
		id: #sidebar;
		id: #content;
		id: #scrollable;
		onChildAt: 1;
		play.

	aScripter check
		label: 'Check repository selected';
		satisfies: [ :aChangeView | aChangeView pages last contentElement tool repository isNotNil ];
		play.

	aScripter check
		label: 'Check repository rendering basics (name is shown)';
		satisfies: [ :aChangeView | 
			((aChangeView pages last contentElement tool childNamed: #content)
				childNamed: #toolbar) children first text asString
				= aChangeView pages last contentElement tool repository name ];
		play.

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
