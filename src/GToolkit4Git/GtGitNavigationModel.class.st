Class {
	#name : #GtGitNavigationModel,
	#superclass : #Object,
	#traits : 'TGtAnnouncer',
	#classTraits : 'TGtAnnouncer classTrait',
	#instVars : [
		'announcer'
	],
	#category : #'GToolkit4Git-UI'
}

{ #category : #announcer }
GtGitNavigationModel >> announcer [
	^ announcer ifNil: [ announcer := Announcer new ]
]

{ #category : #accessing }
GtGitNavigationModel >> repositories [

	^ IceRepository registry copyFrom: 1 to: IceRepository registry size
]
