Class {
	#name : #GtGitNavigationModel,
	#superclass : #Object,
	#traits : 'TGtAnnouncer',
	#classTraits : 'TGtAnnouncer classTrait',
	#instVars : [
		'announcer',
		'repository'
	],
	#category : #'GToolkit4Git-UI'
}

{ #category : #announcer }
GtGitNavigationModel >> announcer [
	^ announcer ifNil: [ announcer := Announcer new ]
]

{ #category : #accessing }
GtGitNavigationModel >> initialize [
	super initialize.

	self announcer
		when: GtGitRepositorySelected
		send: #onSelection:
		to: self.
	self announcer
		when: GtGitRepositoryAddedAndSelected
		send: #onSelection:
		to: self
]

{ #category : #initialization }
GtGitNavigationModel >> onSelection: anAnnouncement [
	repository := anAnnouncement repository
]

{ #category : #accessing }
GtGitNavigationModel >> repositories [

	^ IceRepository registry copyFrom: 1 to: IceRepository registry size
]

{ #category : #accessing }
GtGitNavigationModel >> repository [
	^ repository
]
