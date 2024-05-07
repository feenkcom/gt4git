Class {
	#name : #GtGitCliSignal,
	#superclass : #BeaconSignal,
	#traits : 'TGtBeaconSignalStartEndType',
	#classTraits : 'TGtBeaconSignalStartEndType classTrait',
	#instVars : [
		'args',
		'output'
	],
	#category : #'GToolkit4Git-Libgit-replace'
}

{ #category : #'instance creation' }
GtGitCliSignal class >> args: aCollection [
	^self new args: aCollection
]

{ #category : #'instance creation' }
GtGitCliSignal class >> args: aCollection output: aCollectionOfStrings [
	^ self new
		args: aCollection;
		output: aCollectionOfStrings;
		yourself
]

{ #category : #accessing }
GtGitCliSignal class >> eventType [
	^GtGitCliEvent
]

{ #category : #accessing }
GtGitCliSignal >> args [
	^ args
]

{ #category : #accessing }
GtGitCliSignal >> args: aCollection [
	args := aCollection
]

{ #category : #'gt extensions' }
GtGitCliSignal >> gtGitInvocationFor: aView [
	<gtView>
	^ aView list
		title: 'Git args';
		priority: 30;
		items: [ self args ]
]

{ #category : #'gt extensions' }
GtGitCliSignal >> gtGitOutputFor: aView [
	<gtView>
	^ aView list
		title: 'Git output';
		priority: 35;
		items: [ self output ifNil: [ #() ] ]
]

{ #category : #accessing }
GtGitCliSignal >> output [
	^ output
]

{ #category : #accessing }
GtGitCliSignal >> output: aCollectionOfStrings [
	output := aCollectionOfStrings
]

{ #category : #printing }
GtGitCliSignal >> printOneLineContentsOn: aStream [
	args do: [ :arg | aStream print: arg ] separatedBy: [ aStream nextPut: $  ]
]
