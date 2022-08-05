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
	
	aScripter := BlDevScripter new.
	aScripter element: self expandedElement.
	
	^ aScripter
]

{ #category : #accessing }
GtGitElementExamples >> scripterOnExpandedElementWithAddDialogOpen [
	<noTest>
	<gtExample>
	| aScripter |
	aScripter := self scripterOnExpandedElement.
	aScripter
		substep: 'Click on add dialog'
		do: [ :aStep | aStep click
				label: 'Click search';
				id: #sidebar;
				id: #toolbar;
				onChildAt: 1;
				onChildAt: 1.].

	^ aScripter syncContinue
]

{ #category : #accessing }
GtGitElementExamples >> scripterOnExpandedElementWithDeletedRepository [
	<noTest>
	<gtExample>
	| aScripter |
	aScripter := self scripterOnExpandedElementWithInitializationDone.
	aScripter
		substep: 'Delete repository'
		do: [ :aStep | 
			aStep click
				label: 'Click on delete button';
				id: #content;
				id: #toolbar;
				onChildAt: 2.
				
			aStep click
				label: 'Click on checkbox';
				onSpaceRoot;
				id: #'git-repository-removal-checkbox'.
				
			aStep click
				label: 'Click on remove button';
				onSpaceRoot;
				id: #'change-button-action'.
								
			aStep check
				label: 'Check repository';
				satisfies: [ :aChangeView | aChangeView pages last contentElement tool repository isNil ]. 
			 ].

	^ aScripter syncContinue
]

{ #category : #accessing }
GtGitElementExamples >> scripterOnExpandedElementWithExpandedSearch [
	<gtExample>
	| aScripter |
	aScripter := self scripterOnExpandedElement.
	aScripter
		substep: 'Click on search'
		do: [ :aStep | 
			aStep click
				label: 'Click search';
				id: #sidebar;
				id: #toolbar;
				onChildAt: 1;
				onChildAt: 3 ].

	^ aScripter syncContinue
]

{ #category : #accessing }
GtGitElementExamples >> scripterOnExpandedElementWithInitializationDialogNavigated [
	<gtExample>
	<noTest>
	| aScripter |
	aScripter := self scripterOnExpandedElementWithInitializationDialogOpen.
	aScripter
		substep: 'Click on a directory'
		do: [ :aStep | 
			aStep doubleClick
				label: 'Click on directory';
				onSpaceRoot;
				id: #'git-initialize-page';
				onChildAt: 2;
				id: #scrollable;
				onChildAt: 7 ].

	^ aScripter syncContinue
]

{ #category : #accessing }
GtGitElementExamples >> scripterOnExpandedElementWithInitializationDialogOpen [
	<gtExample>
	<noTest>
	| aScripter |
	aScripter := self scripterOnExpandedElementWithAddDialogOpen.
	(FileLocator imageDirectory / 'zzz') ensureCreateDirectory.
	aScripter
		substep: 'Click on intialization button'
		do: [ :aStep | 
			aStep click
				label: 'Click initialization';
				onSpaceRoot;
				id: #'git-initial' ].

	^ aScripter syncContinue
]

{ #category : #accessing }
GtGitElementExamples >> scripterOnExpandedElementWithInitializationDone [
	<noTest>
	<gtExample>
	| aScripter |
	aScripter := self scripterOnExpandedElementWithInitializationDialogNavigated.
	aScripter
		substep: 'Finalize initialization'
		do: [ :aStep | 
			aStep click
				label: 'Click on directory';
				onSpaceRoot;
				id: #'git-initialize-page';
				onChildAt: 3;
				onChildAt: 1.
								
			aStep check
				label: 'Check repository';
				satisfies: [ :aChangeView | aChangeView pages last contentElement tool repository name = 'zzz' ]. 
			 ].

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
	aScripter
		substep: 'Click on repository'
		do: [ :aStep | 
			aStep check
				label: 'Check no repository';
				satisfies: [ :aChangeView | aChangeView pages last contentElement tool repository isNil ].

			aStep click
				label: 'Click first repository';
				id: #sidebar;
				id: #content;
				id: #scrollable;
				onChildAt: 1.

			aStep check
				label: 'Check repository selected';
				satisfies: [ :aChangeView | aChangeView pages last contentElement tool repository isNotNil ] ].

	^ aScripter syncContinue
]

{ #category : #accessing }
GtGitElementExamples >> simpleElement [
	<gtExample>
	| element |
	element := GtGitElement new.
	
	self assert: element repository equals: nil.
	
	^ element
]
