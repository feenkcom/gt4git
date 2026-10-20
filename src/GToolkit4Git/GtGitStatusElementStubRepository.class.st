"
I am a stub repository for {{gtClass:GtGitStatusElementExamples}}. My {{gtMethod:GtGitStatusElementStubRepository>>#statusModel}} blocks until the example releases it with {{gtMethod:GtGitStatusElementStubRepository>>#releaseStatusModel}}, which simulates a slow `Git` worker. I count how many times status was requested.
"
Class {
	#name : #GtGitStatusElementStubRepository,
	#superclass : #Object,
	#instVars : [
		'viewModel',
		'statusSemaphore',
		'startedSemaphore',
		'statusModelCallCount'
	],
	#category : #'GToolkit4Git-Examples'
}

{ #category : #actions }
GtGitStatusElementStubRepository >> announceModified [
	viewModel announce: GtRepositoryModified new
]

{ #category : #initialization }
GtGitStatusElementStubRepository >> initialize [
	super initialize.
	viewModel := Announcer new.
	statusSemaphore := Semaphore new.
	startedSemaphore := Semaphore new.
	statusModelCallCount := 0
]

{ #category : #actions }
GtGitStatusElementStubRepository >> releaseAllStatusModels [
	"Let all current and future #statusModel calls finish."
	100 timesRepeat: [ statusSemaphore signal ]
]

{ #category : #actions }
GtGitStatusElementStubRepository >> releaseStatusModel [
	statusSemaphore signal
]

{ #category : #accessing }
GtGitStatusElementStubRepository >> statusModel [
	"Block until the example releases me, simulating a slow worker."
	statusModelCallCount := statusModelCallCount + 1.
	startedSemaphore signal.
	statusSemaphore wait.
	^ OrderedCollection with: BlElement new
]

{ #category : #accessing }
GtGitStatusElementStubRepository >> statusModelCallCount [
	^ statusModelCallCount
]

{ #category : #accessing }
GtGitStatusElementStubRepository >> viewModel [
	^ viewModel
]
