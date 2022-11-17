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
		detect: [ :aRepository | aRepository name = 'zzz' ]
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
		onChildAt: 7;
		play.

	^ aScripter
]

{ #category : #examples }
GtGitElementExamples >> scripterOnExpandedElementWithInitializationDialogOpen [
	<gtExample>
	| aScripter |
	aScripter := self scripterOnExpandedElementWithAddDialogOpen.
	(FileLocator imageDirectory / 'zzz') ensureCreateDirectory.
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

	aScripter check
		label: 'Check repository';
		satisfies: [ :aChangeView | aChangeView pages last contentElement tool repository name = 'zzz' ];
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


	aScripter keyClick
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
	<noTest>
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
