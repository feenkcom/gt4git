Class {
	#name : #GtGitStatusUncommittedChanges,
	#superclass : #GtGitStatus,
	#category : #'GToolkit4Git-Model'
}

{ #category : #accessing }
GtGitStatusUncommittedChanges >> icon [
	^ BrGlamorousVectorIcons inspect 
]

{ #category : #accessing }
GtGitStatusUncommittedChanges >> label [
	^ 'Uncommitted Changes'
]
