Class {
	#name : #GtGitRepository,
	#superclass : #Object,
	#instVars : [
		'repository',
		'status',
		'headDescription',
		'isModified'
	],
	#category : #GToolkit4Git
}

{ #category : #'instance creation' }
GtGitRepository class >> fromIcebergRepository: anIceRepository [
	^ self new repository: anIceRepository
]

{ #category : #accessing }
GtGitRepository >> headDescription [
	^ headDescription ifNil: [ headDescription := self repository headDescription ]
]

{ #category : #accessing }
GtGitRepository >> isModified [
	^ isModified ifNil: [ isModified := self repository isModified ]
]

{ #category : #initialization }
GtGitRepository >> load [
	self status.
	self headDescription.
	self isModified
]

{ #category : #accessing }
GtGitRepository >> name [
	^ self repository name
]

{ #category : #accessing }
GtGitRepository >> repository [
	<return: #IceRepository>

	^ repository
]

{ #category : #accessing }
GtGitRepository >> repository: anIceRepository [
	repository := anIceRepository
]

{ #category : #initialization }
GtGitRepository >> reset [
	status := nil.
	headDescription := nil.
	isModified := nil
]

{ #category : #accessing }
GtGitRepository >> status [
	^ status ifNil: [ status := (IceTipRepositoryModel on: self repository) status ]
]
