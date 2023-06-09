Class {
	#name : #GtGitAnnouncement,
	#superclass : #Announcement,
	#instVars : [
		'repository'
	],
	#category : #'GToolkit4Git-UI - View Model'
}

{ #category : #'instance creation' }
GtGitAnnouncement class >> for: aRepository [
	^ self new repository: aRepository
]

{ #category : #accessing }
GtGitAnnouncement >> repository [
	^ repository
]

{ #category : #accessing }
GtGitAnnouncement >> repository: aRepository [
	repository := aRepository
]
