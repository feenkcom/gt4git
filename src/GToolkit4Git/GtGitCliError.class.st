Class {
	#name : #GtGitCliError,
	#superclass : #Error,
	#instVars : [
		'stderr',
		'args',
		'status'
	],
	#category : #'GToolkit4Git-Libgit-replace'
}

{ #category : #accessing }
GtGitCliError >> args [
	^ args
]

{ #category : #accessing }
GtGitCliError >> args: anObject [
	args := anObject
]

{ #category : #accessing }
GtGitCliError >> status [
	^ status
]

{ #category : #accessing }
GtGitCliError >> status: anObject [
	status := anObject
]

{ #category : #accessing }
GtGitCliError >> stderr [
	^ stderr
]

{ #category : #accessing }
GtGitCliError >> stderr: anObject [
	stderr := anObject
]
