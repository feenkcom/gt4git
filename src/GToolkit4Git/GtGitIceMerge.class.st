Class {
	#name : #GtGitIceMerge,
	#superclass : #IceMerge,
	#instVars : [
		'lepiterWorkingCopy'
	],
	#category : #'GToolkit4Git-Model'
}

{ #category : #accessing }
GtGitIceMerge >> lepiterWorkingCopy [
	^ lepiterWorkingCopy
]

{ #category : #accessing }
GtGitIceMerge >> lepiterWorkingCopy: aLepiterWorkingCopy [
	lepiterWorkingCopy := aLepiterWorkingCopy
]

{ #category : #actions }
GtGitIceMerge >> updateWorkingCopy [
	"After a merge was done check to see if changes correspond to Lepiter databases
	that are currently registered. If yes trigger a local reload of those databases."
	super updateWorkingCopy.
	
	self lepiterWorkingCopy 
		loadLepiterChangesInWorkingCopyFrom: self changesToWorkingCopyTree.
]
