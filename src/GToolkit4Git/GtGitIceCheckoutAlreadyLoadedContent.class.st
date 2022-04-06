Class {
	#name : #GtGitIceCheckoutAlreadyLoadedContent,
	#superclass : #IceCheckoutAlreadyLoadedPackages,
	#instVars : [
		'lepiterWorkingCopy'
	],
	#category : #'GToolkit4Git-Lepiter'
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
