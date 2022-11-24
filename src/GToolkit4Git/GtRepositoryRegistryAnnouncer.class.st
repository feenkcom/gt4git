"
nil
"
Class {
	#name : #GtRepositoryRegistryAnnouncer,
	#superclass : #Object,
	#traits : 'TGtAnnouncer + TGtUniqueInstance',
	#classTraits : 'TGtAnnouncer classTrait + TGtUniqueInstance classTrait',
	#instVars : [
		'announcer'
	],
	#category : #'GToolkit4Git-UI - View Model'
}

{ #category : #announcer }
GtRepositoryRegistryAnnouncer >> announcer [
	^ announcer ifNil: [ announcer := Announcer new ]
]

{ #category : #accessing }
GtRepositoryRegistryAnnouncer >> initialize [
	super initialize.
	
	self subscribe.
]

{ #category : #accessing }
GtRepositoryRegistryAnnouncer >> onRepositoryCreated: anAnnouncement [
	self announce: (GtRepositoryAdded for: anAnnouncement repository)
]

{ #category : #accessing }
GtRepositoryRegistryAnnouncer >> onRepositoryForgotten: anAnnouncement [
	self announce: (GtRepositoryRemoved for: anAnnouncement repository)
]

{ #category : #accessing }
GtRepositoryRegistryAnnouncer >> subscribe [
	Iceberg announcer weak when: IceRepositoryCreated send: #onRepositoryCreated: to: self.
	Iceberg announcer weak when: IceRepositoryForgotten send: #onRepositoryForgotten: to: self.
]
