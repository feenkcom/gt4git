Class {
	#name : #GtGitMagrittePane,
	#superclass : #Object,
	#instVars : [
		'acceptAction',
		'cancelAction'
	],
	#category : #'GToolkit4Git-UI'
}

{ #category : #accessing }
GtGitMagrittePane >> acceptAction [
	^ acceptAction ifNil: [ 
		[ :_aModel :aButton  |
			aButton phlow spawnObject: self ] ]
]

{ #category : #accessing }
GtGitMagrittePane >> acceptAction: anAction [
	acceptAction := anAction
]

{ #category : #magritte }
GtGitMagrittePane >> acceptLabel [
	^ 'Accept'
]

{ #category : #converting }
GtGitMagrittePane >> asElement [
	^ self asGtMagritteViewModel asElement padding: (BlInsets all: 10)
]

{ #category : #accessing }
GtGitMagrittePane >> cancelAction [
	^ cancelAction ifNil: [  ]
]

{ #category : #accessing }
GtGitMagrittePane >> cancelAction: anAction [
	cancelAction := anAction
]

{ #category : #magritte }
GtGitMagrittePane >> magritteAcceptAction [
	<magritteActionDescription>
	^ super magritteAcceptAction
		label: self acceptLabel;
		onSuccessCallback: self acceptAction
]

{ #category : #magritte }
GtGitMagrittePane >> magritteCancelAction [
	<magritteActionDescription>
	^ super magritteCancelAction
		onSuccessCallback: self cancelAction
]