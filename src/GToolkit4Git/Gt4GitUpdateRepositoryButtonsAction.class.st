"
I update repositories filter buttons.
"
Class {
	#name : #Gt4GitUpdateRepositoryButtonsAction,
	#superclass : #Object,
	#instVars : [
		'git',
		'buttonsContainer',
		'listElement'
	],
	#category : #'GToolkit4Git-Inspector Integration'
}

{ #category : #'api - accessing' }
Gt4GitUpdateRepositoryButtonsAction >> buttonsContainer [
	^ buttonsContainer
]

{ #category : #'api - accessing' }
Gt4GitUpdateRepositoryButtonsAction >> buttonsContainer: anObject [
	buttonsContainer := anObject
]

{ #category : #'api - accessing' }
Gt4GitUpdateRepositoryButtonsAction >> git [
	^ git
]

{ #category : #'api - accessing' }
Gt4GitUpdateRepositoryButtonsAction >> git: anObject [
	git := anObject
]

{ #category : #'api - accessing' }
Gt4GitUpdateRepositoryButtonsAction >> listElement [
	^ listElement
]

{ #category : #'api - accessing' }
Gt4GitUpdateRepositoryButtonsAction >> listElement: anObject [
	listElement := anObject
]

{ #category : #'api - updating' }
Gt4GitUpdateRepositoryButtonsAction >> update [
	self git
		buildButtonsContainer: self buttonsContainer
		listWidget: self listElement.
]
