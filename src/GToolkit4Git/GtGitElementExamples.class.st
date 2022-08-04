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
