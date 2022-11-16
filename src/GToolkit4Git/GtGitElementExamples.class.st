Class {
	#name : #GtGitElementExamples,
	#superclass : #Object,
	#traits : 'TGtExampleAssertable',
	#classTraits : 'TGtExampleAssertable classTrait',
	#category : #'GToolkit4Git-Examples'
}

{ #category : #accessing }
GtGitElementExamples >> expandedElement [
	<gtExample>
	| element |
	element := self simpleElement createInPager maximized.
	
	^ element
]

{ #category : #accessing }
GtGitElementExamples >> scripterOnExpandedElement [
	<gtExample>
	| aScripter |
	
	aScripter := BlScripter new.
	aScripter element: self expandedElement.
	
	^ aScripter
]

{ #category : #accessing }
GtGitElementExamples >> scripterOnExpandedElementWithAddDialogOpen [
	<noTest>
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

{ #category : #accessing }
GtGitElementExamples >> scripterOnExpandedElementWithDeletedRepository [
	<noTest>
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

{ #category : #accessing }
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

{ #category : #accessing }
GtGitElementExamples >> scripterOnExpandedElementWithInitializationDialogNavigated [
	<gtExample>
	<noTest>
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

{ #category : #accessing }
GtGitElementExamples >> scripterOnExpandedElementWithInitializationDialogOpen [
	<gtExample>
	<noTest>
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

{ #category : #accessing }
GtGitElementExamples >> scripterOnExpandedElementWithInitializationDone [
	<noTest>
	<gtExample>
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

	^ aScripter syncContinue
]

{ #category : #accessing }
GtGitElementExamples >> scripterOnExpandedElementWithSearchResult [
	<noTest>
	<gtExample>
	| aScripter |
	aScripter := self scripterOnExpandedElementWithExpandedSearch.
	aScripter
		substep: 'Type in search'
		do: [ :aStep | 
			aStep check
				label: 'Check no repository';
				satisfies: [ :aChangeView | aChangeView pages last contentElement tool repository isNil ].
				
			aStep type
				label: 'Search for GToolkit repository';
				text: 'gtoolkit'.


			aStep keyClick
				label: 'Select repository';
				key: BlKeyboardKey return.
								
			aStep check
				label: 'Check repository';
				satisfies: [ :aChangeView | aChangeView pages last contentElement tool repository name = 'gtoolkit' ]. ].

	^ aScripter syncContinue
]

{ #category : #accessing }
GtGitElementExamples >> scripterOnExpandedElementWithSelectedRepository [
	<gtExample>
	<noTest>
	| aScripter |
	aScripter := self scripterOnExpandedElement.
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

{ #category : #accessing }
GtGitElementExamples >> simpleElement [
	<gtExample>
	| element |
	element := GtGitElement new.
	
	self assert: element repository equals: nil.
	
	^ element
]
