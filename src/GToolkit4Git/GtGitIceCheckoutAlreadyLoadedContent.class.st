"
This is a stragegy that augments {{gtClass:IceCheckoutAlreadyLoadedPackages}} with support for updating Lepiter databases already loaded inside the image. 

If a database is removed from disk it will also be removed from the in-image working copy.
"
Class {
	#name : #GtGitIceCheckoutAlreadyLoadedContent,
	#superclass : #IceCheckoutAlreadyLoadedPackages,
	#instVars : [
		'lepiterWorkingCopy'
	],
	#category : #'GToolkit4Git-Model'
}

{ #category : #accessing }
GtGitIceCheckoutAlreadyLoadedContent class >> description [
	^ 'Checkout packages and Lepiter databases ALREADY LOADED in the image'
]

{ #category : #accessing }
GtGitIceCheckoutAlreadyLoadedContent class >> order [
	^ 9
]

{ #category : #checkout }
GtGitIceCheckoutAlreadyLoadedContent >> checkoutOn: anIceWorkingCopy [ 
	"Calling super performs a forced checkout. After this updates files from disk, trigger a reload of lepiter databases affected by this change."
	
	super checkoutOn: anIceWorkingCopy.
	lepiterWorkingCopy ifNil: [ ^ self ].
	lepiterWorkingCopy loadLepiterChangesInWorkingCopyFrom: self diff.
]

{ #category : #accessing }
GtGitIceCheckoutAlreadyLoadedContent >> diff [
	
	^ diff ifNil: [ 
		diff := committish diffTo: lepiterWorkingCopy ].
]

{ #category : #accessing }
GtGitIceCheckoutAlreadyLoadedContent >> lepiterWorkingCopy [

	^ lepiterWorkingCopy
]

{ #category : #accessing }
GtGitIceCheckoutAlreadyLoadedContent >> lepiterWorkingCopy: aLepiterWorkingCopy [

	lepiterWorkingCopy := aLepiterWorkingCopy
]
