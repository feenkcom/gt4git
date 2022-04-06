Class {
	#name : #GtGitIceMerge,
	#superclass : #IceMerge,
	#category : #'GToolkit4Git-Lepiter'
}

{ #category : #actions }
GtGitIceMerge >> updateWorkingCopy [
	"After a merge was done check to see if changes correspond to Lepiter databases
	that are currently registered. If yes trigger a local reload of those databases."
	super updateWorkingCopy.
]
