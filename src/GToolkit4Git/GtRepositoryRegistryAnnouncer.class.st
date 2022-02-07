Class {
	#name : #GtRepositoryRegistryAnnouncer,
	#superclass : #Object,
	#traits : 'TGtWithAnnouncer',
	#classTraits : 'TGtWithAnnouncer classTrait',
	#category : #'GToolkit4Git-UI - View Model'
}

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
