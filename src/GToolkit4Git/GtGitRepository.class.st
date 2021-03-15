Class {
	#name : #GtGitRepository,
	#superclass : #Object,
	#traits : 'TGtAnnouncer',
	#classTraits : 'TGtAnnouncer classTrait',
	#instVars : [
		'repository',
		'announcer',
		'isSubscribed'
	],
	#category : #'GToolkit4Git-Model'
}

{ #category : #announcer }
GtGitRepository >> announcer [
	<return: #Announcer>
	^ announcer
]

{ #category : #actions }
GtGitRepository >> fetch [
	self repository fetch.
]

{ #category : #'api - repository' }
GtGitRepository >> headDescription [
	^ self repository ifNotNil: #headDescription ifNil: [ '<missing>' ]
]

{ #category : #initialization }
GtGitRepository >> initialize [
	super initialize.
	announcer := Announcer new.
	isSubscribed := false.
]

{ #category : #'api - repository' }
GtGitRepository >> name [
	^ self repository ifNotNil: #name ifNil: [ '<missing>' ]
]

{ #category : #'private - announcement handling' }
GtGitRepository >> onRepositoryModifiedAnnouncement: anAnnouncement [
	anAnnouncement repository = self repository ifTrue: [ ^ self ].
	
	self announce: anAnnouncement
]

{ #category : #printing }
GtGitRepository >> printOn: aStream [
	super printOn: aStream.
	self repository ifNil: [ ^ self ].
	
	aStream 
		nextPut: $(;
		nextPutAll: self repository name;
		nextPut: $)
]

{ #category : #'api - accessing' }
GtGitRepository >> repository [
	^ repository
]

{ #category : #'api - accessing' }
GtGitRepository >> repository: aRepository [

	repository == aRepository ifTrue: [ ^ self ].
	
	repository := aRepository.
	
	isSubscribed ifTrue: [ ^ self ].
	
	Iceberg announcer weak
		when: IceRepositoryModified
		send: #onRepositoryModifiedAnnouncement:
		to: self.
]
